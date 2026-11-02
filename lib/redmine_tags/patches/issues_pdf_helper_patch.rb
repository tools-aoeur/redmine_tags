module RedmineTags
  module Patches
    module IssuesPdfHelperPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          alias_method :fetch_row_values_without_redmine_tags, :fetch_row_values
          alias_method :fetch_row_values, :fetch_row_values_with_redmine_tags
        end
      end

      module InstanceMethods
        # Core renders the tags association as an object inspect string, so
        # join the tag names; every other column (float rounding,
        # parent.subject, attachments, ...) stays with core.
        def fetch_row_values_with_redmine_tags(issue, query, level)
          values = fetch_row_values_without_redmine_tags(issue, query, level)
          query.inline_columns.each_with_index do |column, i|
            values[i] = issue.tags.map(&:to_s).join(',') if column.name == :tags
          end
          values
        end
      end
    end
  end
end

base = Redmine::Export::PDF::IssuesPdfHelper
patch = RedmineTags::Patches::IssuesPdfHelperPatch
base.send(:include, patch) unless base.included_modules.include?(patch)
