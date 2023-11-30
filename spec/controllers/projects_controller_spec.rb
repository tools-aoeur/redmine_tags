require 'spec_helper'

describe ProjectsController do
  include LoginSupport
  include SetupSupport
  render_views

  context 'when using REST API for getting project''s tags' do
    let(:admin)         { create(:user, :admin) }
    let(:author)        { create(:user) }
    let(:role)          { create(:role, :manager) }
    let(:priority)      { create(:issue_priority) }
    let(:status_open)   { create(:issue_status) }
    let(:status_closed) { create(:issue_status, is_closed: true) }
    let(:tracker)       { create(:tracker, default_status_id: status_open.id) }
    let(:project_1) do
      project = create(:project)
      project.trackers = [tracker]
      project.save!
      member = create(
        :member,
        project_id: project.id,
        role_ids: [role.id],
        user_id: author.id
      )
      create(:member_role, member_id: member.id, role_id: role.id)
      project
    end
    let(:project_2) do
      project = create(:project)
      project.trackers = [tracker]
      project.save!
      member = create(
        :member,
        project_id: project.id,
        role_ids: [role.id],
        user_id: author.id
      )
      create(:member_role, member_id: member.id, role_id: role.id)
      project
    end

    before do
      login_as admin
      create_issue(project_1, %w[a1 a2], author, tracker, status_open, priority)
      create_issue(project_1, %w[a2 a3], author, tracker, status_open, priority)
      create_issue(project_1, %w[a4 a5], author, tracker, status_closed, priority)
      create_issue(project_2, %w[b6 b7], author, tracker, status_closed, priority)
      create_issue(project_2, %w[b8 b9], author, tracker, status_open, priority)
    end

    it 'show action should not include tags when not explicitly specified' do
      get :show, params: { id: project_1.id, format: :json }
      parsed_response = response.parsed_body
      expect(response).to have_http_status(:ok)
      expect(parsed_response['tags']).to be_nil
    end

    it 'show action should include tags when requested' do
      get :show, params: { id: project_2.id, include: 'tags', format: :json }
      project_response = response.parsed_body['project']
      expect(response).to have_http_status(:ok)
      expect(project_response['tags']).not_to be_nil
      expect(project_response['tags'].length).to eq(4)
    end

    it 'index should not include tags when not explicitly specified' do
      get :index, format: :json
      api_response = response.parsed_body['projects']
      expect(response).to have_http_status(:ok)
      expect(api_response).not_to be_nil
      expect(api_response.length).to eq(2)
      expect(api_response.first['tags']).to be_nil
      expect(api_response.last['tags']).to be_nil
    end

    it 'index should include own tags for each project' do
      tags_1 = ActsAsTaggableOn::Tag.where(name: %w[a1 a2 a3 a4 a5]).collect do |tag|
        { 'id' => tag.id, 'name' => tag.name }
      end
      tags_2 = ActsAsTaggableOn::Tag.where(name: %w[b6 b7 b8 b9]).collect do |tag|
        { 'id' => tag.id, 'name' => tag.name }
      end
      get :index, params: { include: 'tags', format: :json }
      expect(response).to have_http_status(:ok)
      api_response = response.parsed_body['projects']
      expect(api_response).not_to be_nil
      expect(api_response.length).to eq(2)
      api_project_1 = api_response.detect { |p| p['id'] == project_1.id }
      api_project_2 = api_response.detect { |p| p['id'] == project_2.id }
      expect(api_project_1).not_to be_nil
      expect(api_project_2).not_to be_nil
      api_tags_1 = api_project_1['tags']
      api_tags_2 = api_project_2['tags']
      expect(api_tags_1).not_to be_nil
      expect(api_tags_1).to match_array(tags_1)
      expect(api_tags_2).not_to be_nil
      expect(api_tags_2).to match_array(tags_2)
    end
  end
end
