require "rails_helper"

RSpec.describe "Admin visitor profile", type: :request do
  let(:admin_user) { create(:admin_user) }

  before { sign_in admin_user }

  it "lets staff set profile attributes on a paper-card visitor" do
    visitor = create(:visitor, :paper_card)

    patch admin_visitor_path(visitor), params: { visitor: { category: "zero_yen_sponsor", company_name: "株式会社テスト", gender: "male", age_band: "forties", resident: "other" } }

    expect(visitor.reload).to have_attributes(category: "zero_yen_sponsor", company_name: "株式会社テスト", gender: "male", age_band: "forties", resident: "other")
  end

  it "shows profile attributes on the visitor page" do
    visitor = create(:visitor, :with_profile)

    get admin_visitor_path(visitor)

    expect(response.body).to include("30代")
  end

  it "renders the index with profile filters" do
    create(:visitor, :with_profile)

    get admin_visitors_path, params: { q: { category_eq: "general" } }

    expect(response).to have_http_status(:ok)
  end
end
