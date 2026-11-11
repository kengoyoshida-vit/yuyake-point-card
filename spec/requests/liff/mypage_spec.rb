require "rails_helper"

RSpec.describe "Liff mypage", type: :request do
  def login_as(visitor)
    result = LineIdTokenVerifier::Result.new(success?: true, line_user_id: visitor.line_user_id, display_name: visitor.display_name)
    allow(LineIdTokenVerifier).to receive(:new).and_return(instance_double(LineIdTokenVerifier, call: result))
    post liff_session_path, params: { id_token: "dummy-token" }
  end

  describe "GET /liff/mypage" do
    it "renders the sunset panel with sunset data when the fetch succeeds" do
      visitor = create(:visitor)
      login_as(visitor)
      sunset_result = SunsetInfoFetcher::Result.new(
        success?: true,
        sunset_at: Time.zone.parse("2026-09-08 18:07:00"),
        dusk_at: Time.zone.parse("2026-09-08 18:36:00"),
      )
      allow(SunsetInfoFetcher).to receive(:new).and_return(instance_double(SunsetInfoFetcher, call: sunset_result))

      get liff_mypage_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('data-controller="sunset-theme"')
    end

    it "falls back to the static panel when the sunset fetch fails" do
      visitor = create(:visitor)
      login_as(visitor)
      allow(SunsetInfoFetcher).to receive(:new).and_return(
        instance_double(SunsetInfoFetcher, call: SunsetInfoFetcher::Result.new(success?: false, error: "fetch_error")),
      )

      get liff_mypage_path

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include('data-controller="sunset-theme"')
    end

    context "profile dialog" do
      before do
        allow(SunsetInfoFetcher).to receive(:new).and_return(
          instance_double(SunsetInfoFetcher, call: SunsetInfoFetcher::Result.new(success?: false, error: "fetch_error")),
        )
      end

      it "shows the dialog to a visitor who has not been prompted yet" do
        login_as(create(:visitor))

        get liff_mypage_path

        expect(response.body).to include('data-controller="profile-dialog"')
      end

      it "does not show the dialog once the visitor has been prompted" do
        login_as(create(:visitor, profile_prompted_at: Time.current))

        get liff_mypage_path

        expect(response.body).not_to include('data-controller="profile-dialog"')
      end
    end
  end
end
