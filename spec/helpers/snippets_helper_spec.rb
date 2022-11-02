# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SnippetsHelper do
  include Gitlab::Routing
  include IconsHelper
  include BadgesHelper

  let_it_be(:public_personal_snippet) { create(:personal_snippet, :public, :repository) }
  let_it_be(:public_project_snippet) { create(:project_snippet, :public, :repository) }

  describe '#embedded_raw_snippet_button' do
    let(:blob) { snippet.blobs.first }
    let(:ref) { blob.repository.root_ref }

    subject { embedded_raw_snippet_button(snippet, blob) }

    context 'for Personal Snippets' do
      let(:snippet) { public_personal_snippet }

      it 'returns view raw button of embedded snippets' do
        expect(subject).to eq(download_link("http://test.host/-/snippets/#{snippet.id}/raw/#{ref}/#{blob.path}"))
      end
    end

    context 'for Project Snippets' do
      let(:snippet) { public_project_snippet }

      it 'returns view raw button of embedded snippets' do
        expect(subject).to eq(download_link("http://test.host/#{snippet.project.path_with_namespace}/-/snippets/#{snippet.id}/raw/#{ref}/#{blob.path}"))
      end
    end

    def download_link(url)
      "<a class=\"gl-button btn btn-default\" target=\"_blank\" rel=\"noopener noreferrer\" title=\"Open raw\" href=\"#{url}\">#{external_snippet_icon('doc-code')}</a>"
    end
  end

  describe '#embedded_snippet_download_button' do
    let(:blob) { snippet.blobs.first }
    let(:ref) { blob.repository.root_ref }

    subject { embedded_snippet_download_button(snippet, blob) }

    context 'for Personal Snippets' do
      let(:snippet) { public_personal_snippet }

      it 'returns download button of embedded snippets' do
        expect(subject).to eq(download_link("http://test.host/-/snippets/#{snippet.id}/raw/#{ref}/#{blob.path}"))
      end
    end

    context 'for Project Snippets' do
      let(:snippet) { public_project_snippet }

      it 'returns download button of embedded snippets' do
        expect(subject).to eq(download_link("http://test.host/#{snippet.project.path_with_namespace}/-/snippets/#{snippet.id}/raw/#{ref}/#{blob.path}"))
      end
    end

    def download_link(url)
      "<a class=\"gl-button btn btn-default\" target=\"_blank\" title=\"Download\" rel=\"noopener noreferrer\" href=\"#{url}?inline=false\">#{external_snippet_icon('download')}</a>"
    end
  end

  describe '#embedded_snippet_copy_button' do
    let(:blob) { snippet.blobs.first }
    let(:ref) { blob.repository.root_ref }

    subject { embedded_copy_snippet_button(blob) }

    context 'for Personal Snippets' do
      let(:snippet) { public_personal_snippet }

      it 'returns copy button of embedded snippets' do
        expect(subject).to eq(copy_button(blob.id.to_s))
      end
    end

    context 'for Project Snippets' do
      let(:snippet) { public_project_snippet }

      it 'returns copy button of embedded snippets' do
        expect(subject).to eq(copy_button(blob.id.to_s))
      end
    end

    def copy_button(blob_id)
      "<button class=\"gl-button btn btn-default copy-to-clipboard-btn\" title=\"Copy snippet contents\" onclick=\"copyToClipboard(&#39;.blob-content[data-blob-id=&quot;#{blob_id}&quot;] &gt; pre&#39;)\">#{external_snippet_icon('copy-to-clipboard')}</button>"
    end
  end

  describe '#snippet_badge' do
    let(:snippet) { build(:personal_snippet, visibility) }

    subject { snippet_badge(snippet) }

    context 'when snippet is private' do
      let(:visibility) { :private }

      it 'returns the snippet badge' do
        expect(subject).to eq gl_badge_tag('private', icon: 'lock')
      end
    end

    context 'when snippet is public' do
      let(:visibility) { :public }

      it 'does not return anything' do
        expect(subject).to be_nil
      end
    end

    context 'when snippet is internal' do
      let(:visibility) { :internal }

      it 'does not return anything' do
        expect(subject).to be_nil
      end
    end
  end

  describe '#snippet_report_abuse_path' do
    let(:snippet) { public_personal_snippet }
    let(:current_user) { create(:user) }

    subject { snippet_report_abuse_path(snippet) }

    it 'returns false if the user cannot submit the snippet as spam' do
      allow(snippet).to receive(:submittable_as_spam_by?).and_return(false)

      expect(subject).to be_falsey
    end

    it 'returns true if the user can submit the snippet as spam' do
      allow(snippet).to receive(:submittable_as_spam_by?).and_return(true)

      expect(subject).to be_truthy
    end
  end
end
