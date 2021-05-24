Given(/The case should be flagged for manual review/) do
  binding.pry
  result = CCMS::ManualReviewDeterminer.new(@legal_aid_application).manual_review_required?
  expect(result).to be true
end

Given(/The case should be flagged for automatic review/) do
  result = CCMS::ManualReviewDeterminer.new(@legal_aid_application).manual_review_required?
  expect(result).to be false
end
