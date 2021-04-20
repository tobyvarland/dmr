class ReportPolicy < ApplicationPolicy

  def index?
    true
  end

  def show?
    true
  end

  def create?
    return false unless user
    authorized_users = self.qc_users + self.sales_users + self.it_admin_users
    return authorized_users.include?(user.email)
  end

  def new?
    create?
  end

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
    authorized_users = self.sales_users + self.it_admin_users
    return authorized_users.include?(user.email)
  end

  def add_upload?
    return false unless user
    authorized_users = self.qc_users + self.sales_users + self.it_admin_users
    return authorized_users.include?(user.email)
  end

end