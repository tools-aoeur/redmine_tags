require_relative '../test_helper'

class IssuesPdfHelperPatchTest < ActiveSupport::TestCase
  include Redmine::Export::PDF::IssuesPdfHelper

  fixtures :projects, :users, :issues, :issue_statuses, :trackers, :enumerations

  RedmineTags::TestCase.create_fixtures("#{Redmine::Plugin.find(:redmine_tags).directory}/test/fixtures/",
                                        %i[taggings tags])

  # The override delegates to core, so core's own issues_pdf_test covers the
  # other columns; this checks the tags column the plugin adds.
  def test_fetch_row_values_should_join_tag_names
    query = IssueQuery.new(project: Project.find(1), name: '_')
    query.column_names = %i[subject tags]
    issue = Issue.find(3)

    id, subject, tags = fetch_row_values(issue, query, 0)
    assert_equal ['3', issue.subject], [id, subject]
    assert_equal %w[Production Security], tags.split(',').sort
  end
end
