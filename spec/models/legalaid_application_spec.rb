require 'rails_helper'

RSpec.describe LegalAidApplication, type: :model do
  subject { described_class.new }

  let!(:applicant) { Applicant.create }

  before do
    subject.applicant_id = applicant.id
  end

  it "is valid with all valid attributes" do
    expect(subject).to be_valid
  end

  it "should belong to an applicant" do
    expect(subject.applicant_id).to eq(applicant.id)
  end
end
