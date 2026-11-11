require "rails_helper"

RSpec.describe "Liff profile", type: :request do
  def login_as(visitor)
    result = LineIdTokenVerifier::Result.new(success?: true, line_user_id: visitor.line_user_id, display_name: visitor.display_name)
    allow(LineIdTokenVerifier).to receive(:new).and_return(instance_double(LineIdTokenVerifier, call: result))
    post liff_session_path, params: { id_token: "dummy-token" }
  end

  describe "unauthenticated access" do
    it "redirects to entry" do
      get liff_profile_path

      expect(response).to redirect_to(liff_entry_path)
    end
  end

  describe "GET /liff/profile" do
    it "renders read-only details with an edit button" do
      login_as(create(:visitor, category: "government", company_name: "前橋市役所", gender: "female", age_band: "thirties", resident: "maebashi"))

      get liff_profile_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("プロフィール設定", "編集する", "行政", "前橋市役所", "30代", "前橋市")
      expect(response.body).not_to include("<form")
    end

    it "shows 未回答 for unset values" do
      login_as(create(:visitor))

      get liff_profile_path

      expect(response.body).to include("未回答")
    end
  end

  describe "GET /liff/profile/edit" do
    it "redirects to entry when unauthenticated" do
      get edit_liff_profile_path

      expect(response).to redirect_to(liff_entry_path)
    end

    it "renders the form" do
      login_as(create(:visitor))

      get edit_liff_profile_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("<form", "保存")
    end
  end

  describe "PATCH /liff/profile" do
    let!(:visitor) { create(:visitor) }

    before { login_as(visitor) }

    it "saves the attributes and marks the visitor as prompted" do
      patch liff_profile_path, params: { visitor: { category: "government", company_name: "前橋市役所", gender: "female", age_band: "thirties", resident: "maebashi" } }

      expect(response).to redirect_to(liff_mypage_path)
      visitor.reload
      expect(visitor).to have_attributes(category: "government", company_name: "前橋市役所", gender: "female", age_band: "thirties", resident: "maebashi")
      expect(visitor.profile_prompted_at).to be_present
    end

    it "re-renders with an error for an invalid value" do
      patch liff_profile_path, params: { visitor: { age_band: "bogus" } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(visitor.reload.age_band).to be_nil
    end

    it "ignores attributes outside the profile allowlist" do
      patch liff_profile_path, params: { visitor: { gender: "male", display_name: "改ざん", card_number: "999999" } }

      visitor.reload
      expect(visitor.display_name).to eq("テスト太郎")
      expect(visitor.card_number).to be_nil
    end

    it "only updates the logged-in visitor" do
      other = create(:visitor)

      patch liff_profile_path, params: { id: other.id, visitor: { gender: "male" } }

      expect(other.reload.gender).to be_nil
      expect(visitor.reload.gender).to eq("male")
    end
  end

  describe "POST /liff/profile/skip" do
    it "marks the visitor as prompted without setting attributes" do
      visitor = create(:visitor)
      login_as(visitor)

      post skip_liff_profile_path

      expect(response).to redirect_to(liff_mypage_path)
      visitor.reload
      expect(visitor.profile_prompted_at).to be_present
      expect(visitor.category).to be_nil
    end
  end
end
