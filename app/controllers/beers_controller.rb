class BeersController < UIViewController
  PER_PAGE = 50

  attr_accessor :style_id
  attr_reader   :data, :fetch_in_progress, :done_fetching

  def viewDidLoad
    super

    self.title           = 'Feed'
    view.backgroundColor = UIColor.whiteColor

    setup_constraints
    load_data
  end

  def setup_constraints
    Motion::Layout.new do |layout|
      layout.view       view
      layout.subviews   'table' => table
      layout.horizontal '|[table]|'
      layout.vertical   '|[table]|'
    end
  end

  def load_data
    @fetch_in_progress = true
    footer.begin_loading

    API.shared.get('beers', styleId: style_id, p: current_page) do |success, operation, response_or_error|
      if success
        @data.concat(response_or_error['data'])

        @current_page += 1

        table.reloadData

        if response_or_error['currentPage'] == response_or_error['numberOfPages']
          @done_fetching = true

          footer.end_loading
        else
          footer.stop_loading
        end
      else
        p "Error: #{response_or_error.localizedDescription}"

        footer.stop_loading
      end

      @fetch_in_progress = false
    end
  end

  def refresh(sender)
    @data = []
    table.reloadData

    @current_page = 1
    load_data

    refresh_control.endRefreshing
  end

  # UITableViewDataSource Methods

  def tableView(table_view, numberOfRowsInSection: section)
    data.count
  end

  def tableView(table_view, cellForRowAtIndexPath: index_path)
    (table_view.dequeueReusableCellWithIdentifier('CELL') || build_cell).tap do |cell|
      cell.textLabel.text = data[index_path.row]['name']
    end
  end

  # UITableViewDelegate Methods

  def tableView(table_view, didSelectRowAtIndexPath: index_path)
    table_view.deselectRowAtIndexPath(index_path, animated: true)
  end

  def tableView(table_view, willDisplayCell: cell, forRowAtIndexPath: index_path)
    unless fetch_in_progress || done_fetching
      header_footer_height  = table_view.tableHeaderView ? table_view.tableHeaderView.size.height : 0
      header_footer_height += table_view.tableFooterView ? table_view.tableFooterView.size.height : 0

      x, y = 0, table_view.contentSize.height - header_footer_height

      bottom_cell_point = CGPointMake(x, y - 5)

      at_last_cell = index_path == table_view.indexPathForRowAtPoint(bottom_cell_point)

      load_data if at_last_cell
    end
  end

  def build_cell
    UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: 'CELL')
  end

  def table
    @table ||= UITableView.new.tap do |table_view|
      table_view.delegate        = self
      table_view.dataSource      = self
      table_view.tableFooterView = footer

      table_view.addSubview(refresh_control)
    end
  end

  def refresh_control
    @refresh_control ||= UIRefreshControl.new.tap do |control|
      control.addTarget(self, action: 'refresh:', forControlEvents: UIControlEventValueChanged)
    end
  end

  def footer
    @footer ||= LoadingFooterView.alloc.initWithFrame([CGPointZero, [view.size.width, 50]])
  end

  def current_page
    @current_page ||= 1
  end

  def data
    @data ||= []
  end
end
