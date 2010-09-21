# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application_controller'

class BlogExtension < Radiant::Extension
  version "1.0"
  description "Add access control to radiant"
  url "http://www.imustardsoft.com"
  
  def activate

    if admin.respond_to? :page
		  #Add a checkbox for enable 'the directory of blog'
		  admin.page.edit.add :parts_bottom, "edit_enable_blog_directory"

		  #Add 'Post time' and 'Post user' in the index page
		  admin.page.index.add :sitemap_head, "index_head_view_posted_time_user", :after => "title_column_header"
		  admin.page.index.add :node, "index_view_posted_time_user", :after => "title_column"
    end
    
    Admin::PagesController.class_eval do
      before_filter :filter_other_page, :only => [:edit]
      def index
        if current_user.bloger
          @homepage = Page.find_by_blog_directory(1)
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
        if current_user.bloger && page.created_by_id != current_user.id && page.id != Page.find_by_blog_directory(1).id
          return
        end
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

    Page.class_eval do
      # Associations
      acts_as_tree :order => 'virtual DESC, created_at DESC'
    end

  end
end
