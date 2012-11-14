# Creators 0.9  [![Build Status](https://secure.travis-ci.org/TheGiftsProject/creators.png)](http://travis-ci.org/TheGiftsProject/creators)

Creators are used to host code dealing with creation of new models and clean up the controllers.

## Usage

Note: The examples are for a Rails 3 app.

* Add our gem to your Gemfile:

`gem 'creators'`

Let's just dive right in to the `ProjectController.rb` example:

```ruby
class ProjectController < ApplicationController

    def create
        if project_creator.save
           redirect_to project_url(project_creator.project)
        else
            Log.error("Could not create project", :errors => project_creator.errors)
            redirect_to error_page_url
        end
    end

    private

    def project_creator
        @_project_creator ||= ProjectCreator.new(params, current_user)
    end
end
```

So as you can see from the controller, this Rails app is for managing projects, and in this app we have the main
Project model. Looking briefly at the code shows that in case the creator save method worked without any issues,
we get a saved model that can be accessed by the `project` method, and we can then call `redirect_to` to that project.

In case something goes wrong, the creator `save` yields false, and we can simply log the errors by accessing `errors`
on our creator.

So that's it, our controller is clean from all the setup that's needed to create a new Project model, and we have a
happy-sad flow, to portroy our controller's story.

Let's take a look at how this was all made possible:

* Our creator for the Project model is called `project_creator.rb` and we put it in `app/creators`:

```ruby
class ProjectCreator < Creators::Base

    def initialize(raw_params, current_user)
        @user = current_user
        super(raw_params)
    end

    def before_build
        error("project", "must be an hash") unless @params[:project].is_a? Hash
    end

    def refine_params
        @params[:project]
    end

    def after_build
        project.members.build(refine_admin)
    end

    def refine_admin
        {
        :role => :admin,
        :name => @user.name
        }
    end
end
```

A Creator requires the `raw_params` from the request, but as you can see in this example we've also initialized
the ProjectCreator with a current_user (Represents the current logged in user in the system), just to show that you
can use it with other data objects / models that are connected to your model (The Project model in this example).

The specific behavior of your Creator is defined in the `refine_params` method and the callback methods, that compose
the Save method Life Cycle. The Creator save method is divided into 2 main steps:

1) `build` - This step simply instantiates a new model (Project in our example) and assigns to it the `raw_params` we've
passed to the Creator. The `refine_params` step by default just uses the `raw_params`, and it can be easily overrided by
using the `refine_params` method. (As shown in our example)
Callback methods: `before_build`, `after_build`

For update operations, if we pass to super a model as the 2nd argument, then that model will be used
in the build process instead of it creating a new one.

2) `save` - Simply calls `@model.save`.
Callback methods: `before_save`, `after_save`

In case something goes wrong, meaning the Creator save method returned false, simply access the `errors` method
to get an array of the errors that occurred.

## Requirements

Ruby 1.8.7+, Rails 3.0+.