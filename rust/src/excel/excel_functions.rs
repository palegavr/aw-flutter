use umya_spreadsheet::{
    Border, Cell, Color, Coordinate, Pane, PaneStateValues, Worksheet,
    helper::coordinate::CellCoordinates,
};

#[derive(Clone, Copy, PartialEq, Eq)]
pub enum TextStyle {
    Normal,
    Bold,
    Italic,
    BoldItalic,
}

#[derive(Clone, Copy, PartialEq, Eq)]
pub enum TextAlignment {
    Left,
    Right,
    Top,
    Bottom,
    VerticalCenter,
    HorizontalCenter,
}

#[derive(Clone, Copy, PartialEq, Eq)]
pub enum TextOrientation {
    Horizontal,
    Vertical,
}

#[derive(Clone, Copy)]
pub enum BorderThickness {
    Thin,
    Medium,
    Thick,
}

fn get_black_color() -> Color {
    let mut black_color = Color::default();
    black_color.set_argb(Color::COLOR_BLACK);
    black_color
}

fn choose_border_thickness(thickness: &BorderThickness) -> &'static str {
    match thickness {
        BorderThickness::Thin => Border::BORDER_THIN,
        BorderThickness::Medium => Border::BORDER_MEDIUM,
        BorderThickness::Thick => Border::BORDER_THICK,
    }
}

pub fn create_cell<T>(val: &str, coordinate: T) -> Cell
where
    T: Into<CellCoordinates>,
{
    let mut cell = Cell::default();
    cell.set_value(val);
    cell.set_coordinate(coordinate);
    cell.get_style_mut().get_alignment_mut().set_wrap_text(true);
    cell.get_style_mut()
        .get_font_mut()
        .set_name("Times New Roman")
        .set_size(10.0);
    cell
}

pub fn create_cell_number<T>(val: f64, coordinate: T, trailing_zeros: bool) -> Cell
where
    T: Into<CellCoordinates>,
{
    let mut cell = Cell::default();
    cell.set_value(format!("{val}"));
    if trailing_zeros {
        cell.get_style_mut()
            .get_number_format_mut()
            .set_format_code("0.00");
    }
    cell.set_coordinate(coordinate);
    cell.get_style_mut().get_alignment_mut().set_wrap_text(true);
    cell.get_style_mut()
        .get_font_mut()
        .set_name("Times New Roman")
        .set_size(10.0);
    cell
}

pub fn cell_set_top_border<'a>(cell: &'a mut Cell, thickness: &BorderThickness) -> &'a mut Cell {
    let borders = cell.get_style_mut().get_borders_mut();
    let black_color = get_black_color();
    borders
        .get_top_border_mut()
        .set_color(black_color.clone())
        .set_border_style(choose_border_thickness(&thickness));
    cell
}

pub fn cell_set_bottom_border<'a>(cell: &'a mut Cell, thickness: &BorderThickness) -> &'a mut Cell {
    let borders = cell.get_style_mut().get_borders_mut();
    let black_color = get_black_color();
    borders
        .get_bottom_border_mut()
        .set_color(black_color.clone())
        .set_border_style(choose_border_thickness(&thickness));
    cell
}

pub fn cell_set_left_border<'a>(cell: &'a mut Cell, thickness: &BorderThickness) -> &'a mut Cell {
    let borders = cell.get_style_mut().get_borders_mut();
    let black_color = get_black_color();
    borders
        .get_left_border_mut()
        .set_color(black_color.clone())
        .set_border_style(choose_border_thickness(&thickness));
    cell
}

pub fn cell_set_right_border<'a>(cell: &'a mut Cell, thickness: &BorderThickness) -> &'a mut Cell {
    let borders = cell.get_style_mut().get_borders_mut();
    let black_color = get_black_color();
    borders
        .get_right_border_mut()
        .set_color(black_color.clone())
        .set_border_style(choose_border_thickness(&thickness));
    cell
}

pub fn cell_set_all_borders<'a>(cell: &'a mut Cell, thickness: &BorderThickness) -> &'a mut Cell {
    cell_set_top_border(cell, thickness);
    cell_set_bottom_border(cell, thickness);
    cell_set_left_border(cell, thickness);
    cell_set_right_border(cell, thickness)
}

pub fn cell_set_text_style<'a>(cell: &'a mut Cell, style: &TextStyle) -> &'a mut Cell {
    let font = cell.get_style_mut().get_font_mut();
    font.set_bold(*style == TextStyle::Bold || *style == TextStyle::BoldItalic);
    font.set_italic(*style == TextStyle::Italic || *style == TextStyle::BoldItalic);
    cell
}

pub fn cell_set_text_alignment<'a>(cell: &'a mut Cell, alignment: &TextAlignment) -> &'a mut Cell {
    let cell_alignment = cell.get_style_mut().get_alignment_mut();
    match *alignment {
        TextAlignment::Left => {
            cell_alignment.set_horizontal(umya_spreadsheet::HorizontalAlignmentValues::Left)
        }
        TextAlignment::Right => {
            cell_alignment.set_horizontal(umya_spreadsheet::HorizontalAlignmentValues::Right)
        }
        TextAlignment::Top => {
            cell_alignment.set_vertical(umya_spreadsheet::VerticalAlignmentValues::Top)
        }
        TextAlignment::Bottom => {
            cell_alignment.set_vertical(umya_spreadsheet::VerticalAlignmentValues::Bottom)
        }
        TextAlignment::VerticalCenter => {
            cell_alignment.set_vertical(umya_spreadsheet::VerticalAlignmentValues::Center)
        }
        TextAlignment::HorizontalCenter => {
            cell_alignment.set_horizontal(umya_spreadsheet::HorizontalAlignmentValues::Center)
        }
    }
    cell
}

pub fn cell_set_text_orientation<'a>(
    cell: &'a mut Cell,
    orientation: &TextOrientation,
) -> &'a mut Cell {
    let alignment = cell.get_style_mut().get_alignment_mut();
    let rotation = if *orientation == TextOrientation::Vertical {
        90
    } else {
        0
    };
    alignment.set_text_rotation(rotation);
    cell
}

pub fn cell_set_color(cell: &mut Cell, argb_color: &str) {
    let font = cell.get_style_mut().get_font_mut();
    font.get_color_mut().set_argb(argb_color);
}

pub fn column_toggle_auto_width(worksheet: &mut Worksheet, x: u32, enable: bool) {
    worksheet
        .get_column_dimension_by_number_mut(&x)
        .set_auto_width(enable);
}

pub fn column_set_width(worksheet: &mut Worksheet, x: u32, width: f64) {
    worksheet
        .get_column_dimension_by_number_mut(&x)
        .set_width(width);
}

pub fn row_set_height(worksheet: &mut Worksheet, y: u32, height: f64) {
    worksheet.get_row_dimension_mut(&y).set_height(height);
}

pub fn freeze_rows(worksheet: &mut Worksheet, rows_to_freeze: u32) {
    {
        let sheet_views_list = worksheet.get_sheet_views_mut().get_sheet_view_list_mut();
        if sheet_views_list.is_empty() {
            worksheet
                .get_sheet_views_mut()
                .add_sheet_view_list_mut(Default::default());
        }
    }
    let sheet_view = &mut worksheet.get_sheet_views_mut().get_sheet_view_list_mut()[0];
    let pane = match sheet_view.get_pane_mut() {
        Some(p) => p,
        None => {
            sheet_view.set_pane(Pane::default());
            sheet_view.get_pane_mut().unwrap()
        }
    };
    let mut coords = Coordinate::default();
    coords.set_col_num(1);
    coords.set_row_num(rows_to_freeze + 1);
    pane.set_vertical_split(rows_to_freeze.into())
        .set_top_left_cell(coords)
        .set_state(PaneStateValues::Frozen);
}
