class Opponent < ApplicationRecord
  CASE_RELATIONSHIP_REGEX = /^relationship_case_(\S+)\?$/.freeze # begins with 'relationship_case_' and ends with a question mark
  CLIENT_RELATIONSHIP_REGEX = /^relationship_client_(\S+)\?$/.freeze # begins with "relationship_client_' and ends with a question mark

  CLIENT_RELATIONSHIP_VALUES = {
    civil_partner: 'Civil partner',
    customer: 'Customer',
    employee: 'Employee',
    employer: 'Employer',
    ex_civil_partner: 'Ex civil partner',
    ex_husband_wife: 'Ex_spouse',
    grandparent: 'Grandparent',
    husband_wife: 'Husband / wife',
    landlord: 'Landlord',
    legal_guardian: 'Legal guardian',
    local_authority: 'Local authority',
    medical_professional: 'Medial professional',
    none: 'None',
    other_family_member: 'Other family members',
    other_party_type: 'Other party type',
    parent: 'Parent',
    property_owner: 'Property owner',
    solicitor_barrister: 'Solicitor / barrister',
    step_parent: 'Step parent',
    supplier: 'Supplier',
    tenant: 'Tenant'
  }.freeze

  CASE_RELATIONSHIP_VALUES = {
    agent: 'Agent',
    child: 'Child',
    intervenor: 'Intevenor',
    opponent: 'Opp',
    guardian: 'Guardian',
    beneficiary: 'Beneficiary',
    interested_party: 'Interested party'
  }.freeze

  def shared_ind
    false
  end

  def assessed_income
    0
  end

  def assessed_assets
    0
  end

  def full_name
    "#{title.capitalize} #{first_name} #{surname}"
  end

  def person?
    opponent_type.capitalize == 'Person'
  end

  def organisation?
    opponent_type.capitalize == 'Organisation'
  end

  def other_party_relationship_to_client
    relationship_to_client.capitalize
  end

  def other_party_relationship_to_case
    relationship_to_case.capitalize
  end

  def method_missing(meth, *args)
    if valid_relationship_to_case_method?(meth)
      case_relationship?(meth)
    elsif valid_relationship_to_client_method?(meth)
      client_relationship?(meth)
    else
      super
    end
  end

  def respond_to_missing?(meth, include_private = false)
    return true if valid_relationship_to_case_method?(meth) || valid_relationship_to_client_method?(meth)

    super
  end

  private

  def valid_relationship_to_case_method?(meth)
    CASE_RELATIONSHIP_REGEX.match(meth.to_s) && CASE_RELATIONSHIP_VALUES.key?(Regexp.last_match(1).to_sym)
  end

  def valid_relationship_to_client_method?(meth)
    CLIENT_RELATIONSHIP_REGEX.match(meth.to_s) && CLIENT_RELATIONSHIP_VALUES.key?(Regexp.last_match(1).to_sym)
  end

  def client_relationship?(meth)
    CLIENT_RELATIONSHIP_REGEX.match meth.to_s
    key = Regexp.last_match(1).to_sym
    relationship_to_client.capitalize == CLIENT_RELATIONSHIP_VALUES[key]
  end

  def case_relationship?(meth)
    CASE_RELATIONSHIP_REGEX.match meth.to_s
    key = Regexp.last_match(1).to_sym
    relationship_to_case.capitalize == CASE_RELATIONSHIP_VALUES[key]
  end
end
