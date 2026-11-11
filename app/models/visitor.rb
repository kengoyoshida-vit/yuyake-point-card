class Visitor < ApplicationRecord
  CARD_NUMBER_DIGITS = 6

  COMPANY_NAME_MAX_LENGTH = 100

  CATEGORY_LABELS = { "general" => "一般", "zero_yen_sponsor" => "0円協賛", "government" => "行政" }.freeze
  GENDER_LABELS = { "male" => "男", "female" => "女", "no_answer" => "未回答" }.freeze
  AGE_BAND_LABELS = {
    "under_10" => "10歳未満", "teens" => "10代", "twenties" => "20代", "thirties" => "30代",
    "forties" => "40代", "fifties" => "50代", "sixties" => "60代", "seventies_plus" => "70代以上"
  }.freeze
  RESIDENT_LABELS = { "maebashi" => "前橋市", "other" => "それ以外" }.freeze

  has_many :stamps, dependent: :destroy
  has_many :events, through: :stamps

  enum :category, { general: 0, zero_yen_sponsor: 1, government: 2 }, prefix: true, validate: { allow_nil: true }
  enum :gender, { male: 0, female: 1, no_answer: 2 }, prefix: true, validate: { allow_nil: true }
  enum :age_band, {
    under_10: 0, teens: 1, twenties: 2, thirties: 3,
    forties: 4, fifties: 5, sixties: 6, seventies_plus: 7
  }, prefix: true, validate: { allow_nil: true }
  enum :resident, { maebashi: 0, other: 1 }, prefix: true, validate: { allow_nil: true }

  validates :display_name, presence: true
  validates :company_name, length: { maximum: COMPANY_NAME_MAX_LENGTH }
  validates :line_user_id, uniqueness: true, allow_nil: true
  validates :card_number, uniqueness: true, allow_nil: true
  validate :line_user_id_or_card_number_present

  before_validation :assign_card_number, on: :create, if: -> { card_number.blank? && line_user_id.blank? }
  before_validation :normalize_company_name

  def rank
    Rank.for_stamp_count(stamps.count)
  end

  # The first-login profile dialog is shown once, to LINE-linked visitors only.
  def needs_profile_prompt?
    line_user_id.present? && profile_prompted_at.nil?
  end

  def sponsor_or_government?
    category_zero_yen_sponsor? || category_government?
  end

  # Creates a visitor for a paper membership card: no LINE account, a
  # system-assigned card_number instead. Retries on the rare chance the
  # generated number collides with one assigned concurrently.
  def self.create_paper_card!(display_name:)
    attempts = 0
    begin
      attempts += 1
      create!(display_name: display_name)
    rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
      raise if attempts >= 5

      retry
    end
  end

  def self.next_card_number
    max = where.not(card_number: nil)
      .where("card_number ~ '^[0-9]+$'")
      .maximum(Arel.sql("card_number::integer")).to_i
    format("%0#{CARD_NUMBER_DIGITS}d", max + 1)
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[id display_name card_number line_user_id created_at category gender age_band resident]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end

  private

  # company_name only makes sense for sponsors/government; drop it otherwise.
  def normalize_company_name
    self.company_name = company_name.to_s.strip.presence
    self.company_name = nil unless sponsor_or_government?
  end

  def assign_card_number
    self.card_number = self.class.next_card_number
  end

  def line_user_id_or_card_number_present
    return if line_user_id.present? || card_number.present?

    errors.add(:base, "line_user_id または card_number のいずれかが必要です")
  end
end
