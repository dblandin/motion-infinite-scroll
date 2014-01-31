class StylesController < UIViewController
  attr_reader :data

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
    API.shared.get('styles') do |success, operation, response_or_error|
      if success
        new_data = response_or_error['data']

        start_index, end_index = data.count, data.count + new_data.count - 1

        data.concat(new_data)

        index_paths = (start_index..end_index).map { |index| NSIndexPath.indexPathForRow(index, inSection: 0) }

        table.insertRowsAtIndexPaths(index_paths, withRowAnimation: UITableViewRowAnimationAutomatic)
      else
        p "Error: #{response_or_error.localizedDescription}"
      end
    end
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

    controller          = BeersController.alloc.init
    controller.style_id = data[index_path.row]['id']

    navigationController.pushViewController(controller, animated: true)
  end

  def build_cell
    UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier: 'CELL')
  end

  def table
    @table ||= UITableView.new.tap do |table_view|
      table_view.delegate   = self
      table_view.dataSource = self
    end
  end

  def data
    @data ||= []
  end
end
