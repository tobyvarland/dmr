class AttachmentPolicy < ApplicationPolicy

  def update?
    return false unless user
    authorized_users = self.qc_users + self.sales_users + self.it_admin_users
    return authorized_users.include?(user.email)
  end

  def edit?
    update?
  end

  def destroy?
    return false unless user
    authorized_users = self.qc_users + self.sales_users + self.it_admin_users
    return authorized_users.include?(user.email)
  end

end