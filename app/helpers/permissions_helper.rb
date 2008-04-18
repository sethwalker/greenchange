module PermissionsHelper
  def editable_groups(user)
    user.superuser? ? Group.find(:all) : user.all_groups
  end
end
