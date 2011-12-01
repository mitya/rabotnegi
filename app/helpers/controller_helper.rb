module ControllerHelper
  def quick_route(*args)
    case 
      when Vacancy === args.first then "/vacancies/#{args.first.slug}"
      else nil
    end
  end

  def absolute_url(*args)
    "#{request.scheme}://#{request.host_with_port}#{url(*args)}"
  end

  # (vacancy) => quick_route
  # (user) => polymorphic
  # (:user, user) => polymorphic
  # (:edit, :user, user) => helper
  def url(*args)
    quick_route(*args) and return
    if Symbol === args.first && Mongoid::Document === args.second || Mongoid::Document === args.first
      polymorphic_path(args)
    else
      send("#{args.shift}_path", *args)
    end
  end
end
