ActiveAdmin.register Post do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end
    permit_params :title, :body, :tag_ids => []

    before_create do |post|
        post.tag_list = params["post"]["tag_list"]
    end

    before_update do |post|     
        post.tag_list = params["post"]["tag_list"]
    end

    form do |f|
        f.inputs do
          f.input :title
          f.input :body, :as => :ckeditor
          f.input :tag_list, :input_html => {:value => f.object.tag_list.join(", ") }, :label => "Tags (separated by commas)".html_safe
        end
        f.actions
    end

    index do
        column (:id) { |post| raw(post.id) }
        column (:title) do |post|
            link_to post.title, admin_post_path(post)
        end
        column (:created_at) { |post| raw(post.created_at) }
        column (:updated_at) { |post| raw(post.updated_at) }
        column (:tag_list) { |post| raw(post.tag_list) }
    end

end
