module Liff
  class ProfilesController < Liff::BaseController
    def show
      @visitor = current_visitor
    end

    def edit
      @visitor = current_visitor
    end

    def update
      @visitor = current_visitor
      @visitor.assign_attributes(profile_params)
      @visitor.profile_prompted_at ||= Time.current

      if @visitor.save
        redirect_to liff_mypage_path, notice: "プロフィールを保存しました"
      else
        render :edit, status: :unprocessable_content
      end
    end

    def skip
      current_visitor.update!(profile_prompted_at: Time.current) if current_visitor.profile_prompted_at.nil?
      redirect_to liff_mypage_path
    end

    private

    def profile_params
      params.fetch(:visitor, {}).permit(:category, :company_name, :gender, :age_band, :resident)
    end
  end
end
