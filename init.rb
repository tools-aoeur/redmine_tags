# frozen_string_literal: true

require_relative 'lib/redmine_tags'

ActiveSupport::Reloader.to_prepare do
  paths = '/lib/redmine_tags/{patches/*_patch,hooks/*_hook}.rb'
  Dir.glob(File.dirname(__FILE__) + paths).each do |file|
    require_dependency file
  end
end

Redmine::Plugin.register :redmine_tags do
  name        'Redmine Tags'
  author      'Aleksey V Zapparov AKA "ixti"'
  description 'Redmine tagging support'
  version     '1.0.1'
  url         'https://github.com/tools-aoeur/redmine_tags'

  requires_redmine version_or_higher: '5.0.0'

  settings \
    default:  {
      issues_sidebar:    'none',
      issues_show_count: 0,
      issues_open_only:  0,
      issues_sort_by:    'name',
      issues_sort_order: 'asc'
    },
    partial: 'tags/settings'
end