# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    user ||= User.new # guest user (not logged in)
    if user.manager?
      can :create, Contract, :employee_id => Employee.where(organization_id: user.organization_id).map(&:id)
      can :read, Contract, :employee_id => Employee.where(organization_id: user.organization_id).map(&:id)
      can :read, Employee, :id => Employee.where(organization_id: user.organization_id).map(&:id)
      can :update, SchedulingPeriod, :organization_id => user.organization_id, :submitted => false
      can :read, SchedulingPeriod, :organization_id => user.organization_id
      can :manage, Specialization, :organization_id => user.organization_id
      can :read, ShiftTemplate, :scheduling_unit_id => SchedulingUnit.joins(:scheduling_period).where(scheduling_periods: {organization_id: user.organization_id})
      can :read, Schedule, :id => Contract.where(employee_id: Employee.where(organization_id: user.organization_id).map(&:id)).map(&:schedule_id)
      # can :update, Employee, :organization_id => user.organization_id
    else
      can :read, Contract, :employee_id => user.id
      can :read, Shift, :schedule_id => Contract.where(employee_id: user.id).map(&:schedule_id)
      can :read, Employee, :id => Employee.where(organization_id: user.organization_id).map(&:id)
      can :read, ShiftTemplate, :scheduling_unit_id => SchedulingUnit.joins(:scheduling_period).where(scheduling_periods: {organization_id: user.organization_id})
      can :read, Shift, :schedule_id => Contract.where(employee_id: user.id).map(&:schedule_id), :shift_template => ShiftTemplate.joins(:scheduling_unit).where(scheduling_units: SchedulingUnit.joins(:scheduling_period).where(scheduling_periods: {organization_id: user.organization_id, submitted: true}).map(&:id))
    end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  end
end
