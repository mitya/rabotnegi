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
    result = quick_route(*args)
    return result if result

    if ApplicationModel === args.first || Symbol === args.first && ApplicationModel === args.second
      polymorphic_path(args)
    else
      send("#{args.shift}_path", *args)
    end
  end
end
