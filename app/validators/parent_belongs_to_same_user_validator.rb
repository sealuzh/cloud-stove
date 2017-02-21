class ParentBelongsToSameUserValidator < ActiveModel::Validator
  def validate(record)
    if record.parent.present? && record.parent.user != record.user
      record.errors[:parent_user_mismatch] << 'Parent ingredient belongs to another user.'
    end
  end
end
