module Liff
  class MypageController < Liff::BaseController
    # Fallback coordinates (Maebashi city hall) used when no event is
    # published today or the event has no venue coordinates configured.
    DEFAULT_LAT = 36.3906
    DEFAULT_LNG = 139.0634

    def show
      @stamps = current_visitor.stamps.includes(:event).order(checked_in_at: :desc)
      @rank = current_visitor.rank
      @next_rank = Rank.ordered.where("min_stamps > ?", @stamps.size).first
      @sunset_info = fetch_sunset_info
      @show_profile_dialog = current_visitor.needs_profile_prompt?
    end

    private

    def fetch_sunset_info
      event = Event.published.where(held_on: Date.current).order(created_at: :desc).first
      lat = event&.venue_lat.presence || DEFAULT_LAT
      lng = event&.venue_lng.presence || DEFAULT_LNG

      result = SunsetInfoFetcher.new(lat: lat, lng: lng).call
      result.success? ? result : nil
    end
  end
end
