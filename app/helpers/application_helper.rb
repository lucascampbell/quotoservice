module ApplicationHelper
  
  def sortable(column,title=nil)
    title = title ? title.titleize : column.titleize
    css_class = "quotes.#{column}" == sort_column ? "current #{sort_direction}" : nil
    direction = "quotes.#{column}" == sort_column && sort_direction == 'asc' ? 'desc' : 'asc'
    link_to title, {:sort=>column, 
      :direction=>direction, 
      :page => params[:page],
      :search_type=>@search_type,
      :search => @search}, 
    {:class => css_class}
  end
  
  def options_for_select_custom
    "<option #{@search_type == 'quote' ? 'selected' : ''}>quote</option><option #{@search_type == 'author' ? 'selected' : ''}> \n
    author</option><option #{@search_type == 'citation' ? 'selected' : ''}> \n
    citation</option><option #{@search_type == 'book' ? 'selected' : ''}> \n
    book</option><option #{@search_type == 'tag' ? 'selected' : ''}>tag</option>
    <option #{@search_type == 'topic' ? 'selected' : ''}>topic</option>".html_safe
  end
end
