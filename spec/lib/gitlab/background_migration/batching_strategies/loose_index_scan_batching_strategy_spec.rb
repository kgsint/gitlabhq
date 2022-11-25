# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::BackgroundMigration::BatchingStrategies::LooseIndexScanBatchingStrategy, '#next_batch' do
  let(:batching_strategy) { described_class.new(connection: ActiveRecord::Base.connection) }
  let(:namespaces) { table(:namespaces) }
  let(:projects) { table(:projects) }
  let(:issues) { table(:issues) }
  let(:issue_base_type_enum_value) { 0 }
  let(:issue_type) { table(:work_item_types).find_by!(namespace_id: nil, base_type: issue_base_type_enum_value) }

  let!(:namespace1) { namespaces.create!(name: 'ns1', path: 'ns1') }
  let!(:namespace2) { namespaces.create!(name: 'ns2', path: 'ns2') }
  let!(:namespace3) { namespaces.create!(name: 'ns3', path: 'ns3') }
  let!(:namespace4) { namespaces.create!(name: 'ns4', path: 'ns4') }
  let!(:namespace5) { namespaces.create!(name: 'ns5', path: 'ns5') }
  let!(:project1) { projects.create!(name: 'p1', namespace_id: namespace1.id, project_namespace_id: namespace1.id) }
  let!(:project2) { projects.create!(name: 'p2', namespace_id: namespace2.id, project_namespace_id: namespace2.id) }
  let!(:project3) { projects.create!(name: 'p3', namespace_id: namespace3.id, project_namespace_id: namespace3.id) }
  let!(:project4) { projects.create!(name: 'p4', namespace_id: namespace4.id, project_namespace_id: namespace4.id) }
  let!(:project5) { projects.create!(name: 'p5', namespace_id: namespace5.id, project_namespace_id: namespace5.id) }

  let!(:issue1) do
    issues.create!(
      title: 'title', description: 'description', project_id: project2.id, work_item_type_id: issue_type.id
    )
  end

  let!(:issue2) do
    issues.create!(
      title: 'title', description: 'description', project_id: project1.id, work_item_type_id: issue_type.id
    )
  end

  let!(:issue3) do
    issues.create!(
      title: 'title', description: 'description', project_id: project2.id, work_item_type_id: issue_type.id
    )
  end

  let!(:issue4) do
    issues.create!(
      title: 'title', description: 'description', project_id: project3.id, work_item_type_id: issue_type.id
    )
  end

  let!(:issue5) do
    issues.create!(
      title: 'title', description: 'description', project_id: project2.id, work_item_type_id: issue_type.id
    )
  end

  let!(:issue6) do
    issues.create!(
      title: 'title', description: 'description', project_id: project4.id, work_item_type_id: issue_type.id
    )
  end

  let!(:issue7) do
    issues.create!(
      title: 'title', description: 'description', project_id: project5.id, work_item_type_id: issue_type.id
    )
  end

  it { expect(described_class).to be < Gitlab::BackgroundMigration::BatchingStrategies::BaseStrategy }

  context 'when starting on the first batch' do
    it 'returns the bounds of the next batch' do
      batch_bounds = batching_strategy
        .next_batch(:issues, :project_id, batch_min_value: project1.id, batch_size: 2, job_arguments: [])

      expect(batch_bounds).to eq([project1.id, project2.id])
    end
  end

  context 'when additional batches remain' do
    it 'returns the bounds of the next batch' do
      batch_bounds = batching_strategy
        .next_batch(:issues, :project_id, batch_min_value: project2.id, batch_size: 3, job_arguments: [])

      expect(batch_bounds).to eq([project2.id, project4.id])
    end
  end

  context 'when on the final batch' do
    it 'returns the bounds of the next batch' do
      batch_bounds = batching_strategy
        .next_batch(:issues, :project_id, batch_min_value: project4.id, batch_size: 3, job_arguments: [])

      expect(batch_bounds).to eq([project4.id, project5.id])
    end
  end

  context 'when no additional batches remain' do
    it 'returns nil' do
      batch_bounds = batching_strategy
        .next_batch(:issues, :project_id, batch_min_value: project5.id + 1, batch_size: 1, job_arguments: [])

      expect(batch_bounds).to be_nil
    end
  end
end
