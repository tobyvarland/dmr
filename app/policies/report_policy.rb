class ReportPolicy < ApplicationPolicy

  def qc_users
    return ["greg.turner@varland.com",
            "tim.hudson@varland.com",
            "mike.mitchell@varland.com"]
  end

  def sales_users
    return ["john.mcguire@varland.com",
            "chris.terry@varland.com",
            "art.mink@varland.com",
            "kevin.marsh@varland.com"]
  end

  def it_admin_users
    return ["toby.varland@varland.com",
            "mark.strader@varland.com"]
  end

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

  def remove_upload?
    return false unless user
    authorized_users = self.qc_users + self.sales_users + self.it_admin_users
    return authorized_users.include?(user.email)
  end

  def add_upload?
    return false unless user
    authorized_users = self.qc_users + self.sales_users + self.it_admin_users
    return authorized_users.include?(user.email)
  end

end