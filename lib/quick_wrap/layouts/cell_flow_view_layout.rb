module QuickWrap

  module CellFlowViewLayout

    # opts[:cells_per_row] - number of cells per row
    def self.position_rows_as_grid(cfv, opts={})
      col_view = cfv.col_view
      rows = cfv.rows
      # get layout vars
      cells_per_row = opts[:cells_per_row] || 3
      insets = col_view.collectionViewLayout.inset
      spacing = col_view.collectionViewLayout.spacing
      vw = col_view.frame.size.width
      vwr = vw - insets.left - insets.right
      vwt = vwr - (cells_per_row - 1) * spacing

      # determine tile size
      tw = (vwt / cells_per_row).to_i
      th = tw
      cx = insets.left
      cy = insets.top
      cxt = cx
      cyt = cy

      rows.each do |row|
        if row[:type].to_s.include?("header")
          rw = row[:width] = vwr
          cfv.set_scope_layout(row)
          rh = row[:height]
          row[:frame] = CGRectMake(cx, cy, rw, rh)
          cx = insets.left
          cy += (rh + spacing)
          cxt = cx
          cyt = cy
        else
          row[:width] = tw
          cfv.set_scope_layout(row)
          row[:frame] = CGRectMake(cxt, cyt, tw, th)
          cxt = cxt + tw + spacing
          if (cxt + tw) > vw - insets.right
            cxt = insets.left
            cyt += (th + spacing)
            cy = cyt
          else
            cy = cyt + th + spacing
          end
        end
      end

    end

    def self.position_rows_as_carousel(cfv, opts={})
      col_view = cfv.col_view
      rows = cfv.rows
      insets = col_view.collectionViewLayout.inset
      spacing = col_view.collectionViewLayout.spacing
      vh = col_view.size.height
      vht = vh - insets.top - insets.bottom

      cx = insets.left
      rows.each do |row|
        rw = row[:width]
        row[:frame] = CGRectMake(cx, insets.top, rw, vht)
        cx += rw + spacing
      end

    end

    # opts[:cols] - number of columns
    def self.position_rows_as_pins(cfv, opts={})
      col_view = cfv.col_view
      rows = cfv.rows
      cols = opts[:cols] || 2
      insets = col_view.collectionViewLayout.inset
      spacing = col_view.collectionViewLayout.spacing
      vw = col_view.frame.size.width
      vwi = vw - insets.left - insets.right
      vwt = vwi - (cols - 1) * spacing
      heights = []; cols.times {heights << spacing}

      # determine cell size
      tw = (vwt / cols).to_i

      rows.each do |row|
        if row[:type] == opts[:header_type]
          # this is header row
          rw = row[:width] = vwi
          cfv.set_scope_layout(row)
          rh = row[:height]
          cx = insets.left
          max = heights.max
          cy = max
          heights.each_index {|i| heights[i] = (max + rh + spacing)}
        else
          rw = row[:width] = tw
          cfv.set_scope_layout(row)
          rh = row[:height]
          col_idx = heights.index(heights.min)
          cx = insets.left + (rw + spacing) * col_idx
          cy = heights[col_idx]
          heights[col_idx] += (rh + spacing)
        end

        row[:frame] = CGRectMake(cx, cy, rw, rh)
      end
    end

  end

end
