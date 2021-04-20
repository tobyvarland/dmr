class ApplicationPolicy

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

  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.all
    end
  end
end
