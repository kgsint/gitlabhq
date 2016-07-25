@BoardsStore =
  state:
    boards: []
    done: {}
    filters:
      author: {}
      assignee: {}
      milestone: {}
  moveBoard: (oldIndex, newIndex) ->
    boardFrom = _.find BoardsStore.state.boards, (board) ->
      board.index is oldIndex

    service.updateBoard(boardFrom.id, newIndex)

    boardTo = _.find BoardsStore.state.boards, (board) ->
      board.index is newIndex

    boardFrom.index = newIndex
    if newIndex > boardTo.index
      boardTo.index--
    else
      boardTo.index++
  moveCardToBoard: (boardFromId, boardToId, issueId, toIndex) ->
    boardFrom = _.find BoardsStore.state.boards, (board) ->
      board.id is boardFromId
    boardTo = _.find BoardsStore.state.boards, (board) ->
      board.id is boardToId
    issue = _.find boardFrom.issues, (issue) ->
        issue.id is issueId
    issueBoards = BoardsStore.getBoardsForIssue(issue)

    # Remove the issue from old board
    boardFrom.issues = _.reject boardFrom.issues, (issue) ->
      issue.id is issueId

    # Add to new boards issues
    boardTo.issues.splice(toIndex, 0, issue)

    if boardTo.id is 'done' and issueBoards.length > 1
      Vue.set(BoardsStore.state.done, 'board', boardFrom)
      Vue.set(BoardsStore.state.done, 'issue', issue)
      Vue.set(BoardsStore.state.done, 'boards', issueBoards)
    else if boardTo.id is 'done' and boardFrom.id != 'backlog'
      issue.labels = _.reject issue.labels, (label) ->
        label.title is boardFrom.title
    else
      if boardTo.label?
        BoardsStore.removeIssueFromBoard(issue, boardTo)

        unless foundLabel?
          issue.labels.push(boardTo.label)
  removeIssueFromBoards: (issue, boards) ->
    boardLabels = _.map boards, (board) ->
      board.label.title

    issue.labels = _.reject issue.labels, (label) ->
      boardLabels.indexOf(label.title) != -1
  removeIssueFromBoard: (issue, board) ->
    issue.labels = _.reject issue.labels, (label) ->
      label.title is board.title
  getBoardsForIssue: (issue) ->
    _.filter BoardsStore.state.boards, (board) ->
      foundIssue = _.find board.issues, (boardIssue) ->
        issue?.id == boardIssue?.id
      foundIssue?
  clearDone: ->
    Vue.set(BoardsStore.state, 'done', {})
