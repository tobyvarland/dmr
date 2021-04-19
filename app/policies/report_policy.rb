class ReportPolicy < ApplicationPolicy

  def show?
    return true
  end

  def destroy?
    user && user.employee_number >= 900
  end

  def create?
    user && user.employee_number >= 900
  end

  def edit?
    user && user.employee_number != 937
  end

  def update?
    user && user.employee_number >= 900
  end

  def remove_upload?
    user && user.employee_number >= 900
  end

  def add_upload?
    user && user.employee_number >= 900
  end

end