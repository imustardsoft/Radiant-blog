class BlogExtension < Radiant::Extension
  version "1.0"
  description "Add the 'Access Control' for blog to page"
  url "http://www.imustardsoft.com"
  
  
  def activate
    tab 'Content' do
      add_item "New Blog", "/admin/pages/4/children/new", :after => "Pages"
    end

    #Add a checkbox for enable 'the directory of blog'
    admin.page.edit.add :parts_bottom, "edit_enable_blog_directory"
    #Add a bloger role in 'add user' page
    admin.user.edit[:form].delete("edit_roles")
    admin.user.edit.add :form, "role", :after => "edit_password"
    #Add 'Post time' and 'Post user' in the index page
    admin.page.index.add :sitemap_head, "index_head_view_posted_time_user", :after => "title_column_header"
    admin.page.index.add :node, "index_view_posted_time_user", :after => "title_column"
    #Delete the 'Add child' node and filter 'remove node'
    admin.page.index[:node].delete("add_child_column")
    admin.page.index[:node].delete("remove_column")
    admin.page.index.add :node, "index_view_remove"

    admin.page.index.add :sitemap_head, "index_head_view_add_page", :before => "title_column_header"

    Admin::PagesController.class_eval do
      before_filter :filter_other_page, :only => [:edit]
      #According to the different user filter the page
      def index
        directory_id = Page.find_by_blog_directory(1).id
        if current_user.bloger && directory
          @homepage = Page.find_by_id(directory_id)
        else
          @homepage = Page.find_by_parent_id(nil)
        end
        response_for :plural
      end

      private
        def filter_other_page
          if current_user.bloger && Page.find_by_id(params[:id]).created_by_id != current_user.id
            redirect_to admin_pages_path
            flash[:notice] = t 'You do not have permission to access, the request is denied'
          end
        end
    end

    Admin::NodeHelper.class_eval do
      def render_node(page, locals = {}) 
        return if current_user.bloger && !page.blog_directory && page.created_by_id != current_user.id
        @current_node = page
        locals.reverse_merge!(:level => 0, :simple => false).merge!(:page => page)
        render :partial => 'node', :locals =>  locals
      end
    end

    Admin::UsersHelper.class_eval do
      def roles(user)
        roles = []
        roles << I18n.t('admin') if user.admin?
        roles << I18n.t('designer') if user.designer?
        roles << I18n.t('bloger') if user.bloger?
        roles.join(', ')
      end
    end
  end
end
