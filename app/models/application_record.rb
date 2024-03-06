class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  self.primary_key = 'id'

  attribute :id, :uuid, default: 'gen_random_uuid()'
end
