# Creators 0.9  [![Build Status](https://secure.travis-ci.org/TheGiftsProject/Creators.png)](http://travis-ci.org/TheGiftsProject/Creators)

Creators help you clean up your controllers from the setup that's required for creating or updating your model.
For the most basic situations simply creating a Creator and passing into it the request params, will just work for
creating a new model, but if you'll require adding custom validations, slicing up garbage params or refining a new
Hash of params to be used for the Model attributes, then a Creator is also the home for all that.

## Installation

Just add the creators gem to your Gemfile

`gem 'creators'`

## Usage

This example shows a very simple happy-sad flow for creating a project model using a creator.
We can access the newely created project model when the creation is successful or the errors array if it's not.

```ruby
class ProjectController < ApplicationController

    def create
        project_creator = ProjectCreator.new(params, current_user)
        if project_creator.save
           redirect_to project_url(project_creator.project)
        else
            logger.fatal "Could not create project. Error list: #{project_creator.errors.join(", "}")
            redirect_to error_page_url
        end
    end

end
```

## Defining a creator

We recommend puting all your creator objects in `app/creators`.
Here's how we defined our projects creator

```
 |--
 `--
```
 


```ruby
class ProjectCreator < Creators::Base

    def initialize(raw_params, current_user)
        @user = current_user
        super(raw_params)
    end

    def before_build # optional
        error("project", "must be an hash") unless @params[:project].is_a? Hash
    end

    def refine_params # optional
        @params[:project]
    end

    def after_build # optional
        project.members.build(refined_admin)
    end

    private

    def refined_admin
        {
        :role => :admin,
        :name => @user.name
        }
    end
end
```

A Creator simply requires the `raw_params` from the request, 
you can also add any other data that you might need. 
For example in the ProjectsCreator we need the current_user.

The specific behavior of your Creator is defined in the `refine_params` method and the callback methods, that compose
the Save method Life Cycle. The Creator `save` method is divided into 2 main steps:

1) `build` - This step simply instantiates a new model (Project in our example) and assigns to it the `raw_params` we've
passed to the Creator. The `refine_params` step by default just uses the `raw_params`, and it can be easily overrided by
using the `refine_params` method. (As shown in our example)
Callback methods: `before_build`, `after_build`

2) `save` - Simply calls `@model.save`.
Callback methods: `before_save`, `after_save`

## Want to update your model? No problems!

Here's an example for a creator for the Task model, it relates to the Project model with a belongs_to association.

```ruby
class TaskController < ApplicationController

    def update
        current_task = current_project.tasks.find_by_id(params[:task][:id])

        task_creator = TaskCreator.new(params, current_task)
        if task_creator.save
            render :json => task_creator.task
        else
            logger.fatal "Could not update task for project #{current_project.id}. Error list: #{task_creator.errors.join(", "}")
        end
    end

end

class TaskCreator < Creators::Base

    def initialize(raw_params, current_task)
        @task = task
        super(raw_params, @task)
    end

    def refine_params
        params[:task]
    end

end
```

For update operations, if we pass to super a model as the 2nd argument, then that model will be used
in the build process instead of it creating a new one, in case that model isn't nil.


## Requirements

Ruby 1.8.7+, Rails 3.0+.