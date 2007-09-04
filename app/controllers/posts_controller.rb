class PostsController < ApplicationController

  def create    
    begin
      @page = Page.find params[:page_id]
      current_user.may!(:comment, @page)
      @post = Post.new params[:post]
      @page.build_post(@post,current_user)
      @post.save!
      current_user.updated(@page)
      respond_to do |wants|
        wants.html {
          redirect_to page_url(@page)#, :anchor => @page.discussion.posts.last.dom_id)
          # :paging => params[:paging] || '1')
        }
        wants.xml {
          render :xml => @post.to_xml, :status => 500
        }
      end
      return
    rescue ActiveRecord::RecordInvalid
      msg = @post.errors.full_messages.to_s
    rescue PermissionDenied
      msg = 'you do not have permission to do that'
    end
    flash[:bad_reply] = msg
    respond_to do |wants|
      wants.html {
        redirect_to page_url(@page, :anchor => 'reply-form')
        #, :paging => params[:paging] || '1')
      }
      wants.xml {
        render :xml => msg, :status => 400
      }
    end
  end
 
  def edit
  end
  
  def save
    if params[:save]
      @post.update_attribute('body', params[:body])
    elsif params[:destroy]
      @post.destroy
      return(render :action => 'destroy')
    end
  end
  
  def twinkle
    post = Post.find(params[:id])

    # twinkle control doesn't disappear quickly enough,
    # so store last_twinkled_post in the session to prevent
    # double click from adding two twinkles
    if post != session[:last_twinkled_post]
      session[:last_twinkled_post] = post
      rating = Rating.new(:rating => 1, :user_id => current_user.id)
      @post.ratings << rating
    end
  end

  def untwinkle
    post = Post.find(params[:id])
    Rating.delete_all(["rateable_id = ? AND user_id =?",
      @post.id, current_user.id])
    session[:last_twinkled_post] = nil
  end

  def destroy
  end
  
  def authorized?
    @post = Post.find(params[:id]) if params[:id]
    #incorrect permissions for twinkling
    # should only allow those in group to twinkle?
    if @post and not params[:action] == 'twinkle' and not params[:action] == 'untwinkle' 
      return current_user == @post.user
    else
      return true
    end
  end

end

