use umya_spreadsheet::{Spreadsheet, Worksheet, new_file_empty_worksheet, writer};

use crate::{
    excel::data::{
        ExportedData, OutputHoursRow, OutputMainRateAndHours, OutputMainTable, OutputMainWorkerRow,
        OutputPersonalSemesterRow, OutputPersonalTable, OutputPersonalTables,
    },
    excel::excel_functions::{
        BorderThickness, TextAlignment, TextOrientation, TextStyle, cell_set_all_borders,
        cell_set_bottom_border, cell_set_color, cell_set_left_border, cell_set_right_border,
        cell_set_text_alignment, cell_set_text_orientation, cell_set_text_style,
        cell_set_top_border, column_set_width, create_cell, create_cell_number, freeze_rows,
        row_set_height,
    },
};

pub fn generate_output_file(file_path: &str, data: ExportedData) {
    let mut book = new_file_empty_worksheet();

    write_main_table(&mut book, data.year, &data.type_name, &data.main_table);
    write_additional_tables(&mut book, data.year, &data.type_name, &data.personal_tables);

    let path = std::path::Path::new(file_path);
    let _ = writer::xlsx::write(&book, path);
}

fn write_main_table(
    book: &mut Spreadsheet,
    year: u32,
    type_name: &str,
    main_table: &OutputMainTable,
) {
    let sheet = book.new_sheet("Загальна").unwrap();
    write_table_title(sheet, year, type_name, 1, true, 18);
    write_main_table_header(sheet);
    write_main_table_content(sheet, main_table);
}

fn write_additional_tables(
    book: &mut Spreadsheet,
    year: u32,
    type_name: &str,
    tables_list: &Vec<OutputPersonalTables>,
) {
    for tables in tables_list {
        let sheet = book.new_sheet(&tables.worker_last_name).unwrap();
        let mut height_offset = 1;
        for table in &tables.tables {
            write_table_title(sheet, year, type_name, height_offset, false, 23);
            height_offset += 4;
            write_additional_table_header(sheet, height_offset);
            height_offset += 2;
            let table_height = write_additional_table_content(sheet, height_offset, table);
            height_offset += table_height + 8;
        }
    }
}

fn write_table_title(
    sheet: &mut Worksheet,
    year: u32,
    header_name: &str,
    position_y: u32,
    do_freeze_rows: bool,
    length: u32,
) {
    let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    let letter = letters.chars().nth((length % 26) as usize).unwrap();
    sheet.add_merge_cells(&format!("A{}:{}{}", position_y, letter, position_y));
    sheet.add_merge_cells(&format!("A{}:{}{}", position_y + 1, letter, position_y + 1));
    sheet.add_merge_cells(&format!("A{}:{}{}", position_y + 2, letter, position_y + 2));
    sheet.add_merge_cells(&format!("A{}:{}{}", position_y + 3, letter, position_y + 3));

    if do_freeze_rows {
        freeze_rows(sheet, 7);
    }

    let mut header_1_cell = create_cell(
        "ДНІПРОВСЬКИЙ НАЦІОНАЛЬНИЙ УНІВЕРСИТЕТ ІМЕНІ ОЛЕСЯ ГОНЧАРА",
        (1, position_y),
    );
    let mut header_2_cell = create_cell(
        &format!(
            "Розподіл навчального навантаження між викладачами кафедри {}",
            header_name
        ),
        (1, position_y + 1),
    );
    let mut header_3_cell = create_cell(
        &format!("на {}-{} навчальний рік", year, year + 1),
        (1, position_y + 2),
    );

    cell_set_text_alignment(&mut header_1_cell, &TextAlignment::HorizontalCenter);
    cell_set_text_alignment(&mut header_2_cell, &TextAlignment::HorizontalCenter);
    cell_set_text_alignment(&mut header_3_cell, &TextAlignment::HorizontalCenter);

    cell_set_text_style(&mut header_1_cell, &TextStyle::Bold);
    cell_set_text_style(&mut header_2_cell, &TextStyle::Bold);
    cell_set_text_style(&mut header_3_cell, &TextStyle::Bold);

    sheet.set_cell(header_1_cell);
    sheet.set_cell(header_2_cell);
    sheet.set_cell(header_3_cell);
}

fn write_main_table_header(sheet: &mut Worksheet) {
    sheet.add_merge_cells("A5:A6");
    sheet.add_merge_cells("B5:B6");
    sheet.add_merge_cells("C5:C6");
    sheet.add_merge_cells("D5:D6");
    sheet.add_merge_cells("E5:E6");
    sheet.add_merge_cells("F5:S5");

    row_set_height(sheet, 6, 74.0);
    column_set_width(sheet, 1, 4.0);
    column_set_width(sheet, 2, 20.0);
    column_set_width(sheet, 3, 16.0);
    column_set_width(sheet, 4, 6.0);
    column_set_width(sheet, 5, 16.0);

    for i in 1..=19 {
        let mut cell = create_cell(&format!("{}", i), (i, 7));
        cell_set_text_alignment(&mut cell, &TextAlignment::HorizontalCenter);
        cell_set_text_style(&mut cell, &TextStyle::BoldItalic);
        cell_set_all_borders(&mut cell, &BorderThickness::Medium);
        sheet.set_cell(cell);
    }

    let mut cell_n = create_cell("№ з/п", (1, 5));
    cell_set_text_orientation(&mut cell_n, &TextOrientation::Vertical);
    cell_set_text_style(&mut cell_n, &TextStyle::Bold);
    cell_set_text_alignment(&mut cell_n, &TextAlignment::VerticalCenter);
    cell_set_text_alignment(&mut cell_n, &TextAlignment::HorizontalCenter);
    cell_set_all_borders(&mut cell_n, &BorderThickness::Medium);
    cell_set_all_borders(sheet.get_cell_mut((1, 6)), &BorderThickness::Medium);
    sheet.set_cell(cell_n);

    let mut cell_name = create_cell("Прізвище, ім'я та по батькові (повністю)", (2, 5));
    cell_set_text_style(&mut cell_name, &TextStyle::Bold);
    cell_set_text_alignment(&mut cell_name, &TextAlignment::VerticalCenter);
    cell_set_text_alignment(&mut cell_name, &TextAlignment::HorizontalCenter);
    cell_set_all_borders(&mut cell_name, &BorderThickness::Medium);
    cell_set_all_borders(sheet.get_cell_mut((2, 6)), &BorderThickness::Medium);
    sheet.set_cell(cell_name);

    let mut cell_rank = create_cell("Посада, вчене звання, вчена ступінь", (3, 5));
    cell_set_text_style(&mut cell_rank, &TextStyle::Bold);
    cell_set_text_alignment(&mut cell_rank, &TextAlignment::VerticalCenter);
    cell_set_text_alignment(&mut cell_rank, &TextAlignment::HorizontalCenter);
    cell_set_all_borders(&mut cell_rank, &BorderThickness::Medium);
    cell_set_all_borders(sheet.get_cell_mut((3, 6)), &BorderThickness::Medium);
    sheet.set_cell(cell_rank);

    let mut cell_rate = create_cell("Ставка", (4, 5));
    cell_set_text_orientation(&mut cell_rate, &TextOrientation::Vertical);
    cell_set_text_style(&mut cell_rate, &TextStyle::Bold);
    cell_set_text_alignment(&mut cell_rate, &TextAlignment::VerticalCenter);
    cell_set_text_alignment(&mut cell_rate, &TextAlignment::HorizontalCenter);
    cell_set_all_borders(&mut cell_rate, &BorderThickness::Medium);
    cell_set_all_borders(sheet.get_cell_mut((4, 6)), &BorderThickness::Medium);
    sheet.set_cell(cell_rate);

    let mut cell_semester_empty = create_cell("", (5, 5));
    cell_set_all_borders(&mut cell_semester_empty, &BorderThickness::Medium);
    cell_set_all_borders(sheet.get_cell_mut((5, 6)), &BorderThickness::Medium);
    sheet.set_cell(cell_semester_empty);

    let mut cell_types_of_workload = create_cell("ВИДИ НАВЧАЛЬНОГО НАВАНТАЖЕННЯ", (6, 5));
    cell_set_text_style(&mut cell_types_of_workload, &TextStyle::Bold);
    cell_set_text_alignment(&mut cell_types_of_workload, &TextAlignment::VerticalCenter);
    cell_set_text_alignment(
        &mut cell_types_of_workload,
        &TextAlignment::HorizontalCenter,
    );
    cell_set_all_borders(&mut cell_types_of_workload, &BorderThickness::Medium);
    for i in 7..=19 {
        cell_set_all_borders(sheet.get_cell_mut((i, 5)), &BorderThickness::Medium);
    }
    sheet.set_cell(cell_types_of_workload);

    let workload_types = vec![
        "Лекції",
        "Практичні (семінарські) заняття",
        "Лабораторні роботи",
        "Екзамени",
        "Консультації перед екзаменами",
        "Заліки",
        "Випускні кваліфікаційні роботи",
        "Виробнича практика",
        "Навчальна практика",
        "Поточні консультації",
        "Індивідуальні",
        "Курсові роботи",
        "Керівництво аспірантами",
        "Всього",
    ];

    let mut x = 6;
    for wl_type in workload_types {
        let mut cell_workload_type = create_cell(wl_type, (x, 6));
        cell_set_text_orientation(&mut cell_workload_type, &TextOrientation::Vertical);
        cell_set_text_style(&mut cell_workload_type, &TextStyle::Bold);
        cell_set_text_alignment(&mut cell_workload_type, &TextAlignment::VerticalCenter);
        cell_set_text_alignment(&mut cell_workload_type, &TextAlignment::HorizontalCenter);
        cell_set_all_borders(&mut cell_workload_type, &BorderThickness::Medium);
        sheet.set_cell(cell_workload_type);
        x += 1;
    }
}

fn write_main_table_content(sheet: &mut Worksheet, main_table: &OutputMainTable) {
    let mut position_y = 8;
    let mut number = 1;
    for head in &main_table.heads {
        write_main_table_content_row(
            sheet,
            position_y,
            number,
            &head.last_name,
            &head.middle_name,
            &head.first_name,
            &head.rank,
            &head.rate_and_hours,
            false,
        );
        position_y += 3;
        number += 1;
    }
    write_main_table_content_row(
        sheet,
        position_y,
        0,
        "Всього за зав. каф.",
        "",
        "",
        "",
        &main_table.heads_total,
        true,
    );
    position_y += 3;
    for professor in &main_table.professors {
        write_main_table_content_row(
            sheet,
            position_y,
            number,
            &professor.last_name,
            &professor.middle_name,
            &professor.first_name,
            &professor.rank,
            &professor.rate_and_hours,
            false,
        );
        position_y += 3;
        number += 1;
    }
    write_main_table_content_row(
        sheet,
        position_y,
        0,
        "Всього за професорами",
        "",
        "",
        "",
        &main_table.professors_total,
        true,
    );
    position_y += 3;
    for a_professor in &main_table.associate_professors {
        write_main_table_content_row(
            sheet,
            position_y,
            number,
            &a_professor.last_name,
            &a_professor.middle_name,
            &a_professor.first_name,
            &a_professor.rank,
            &a_professor.rate_and_hours,
            false,
        );
        position_y += 3;
        number += 1;
    }
    write_main_table_content_row(
        sheet,
        position_y,
        0,
        "Всього за доцентами",
        "",
        "",
        "",
        &main_table.associate_professors_total,
        true,
    );
    position_y += 3;
    for lecturer in &main_table.lecturers {
        write_main_table_content_row(
            sheet,
            position_y,
            number,
            &lecturer.last_name,
            &lecturer.middle_name,
            &lecturer.first_name,
            &lecturer.rank,
            &lecturer.rate_and_hours,
            false,
        );
        position_y += 3;
        number += 1;
    }
    write_main_table_content_row(
        sheet,
        position_y,
        0,
        "Всього за викладачами",
        "",
        "",
        "",
        &main_table.lecturers_total,
        true,
    );
    position_y += 3;
    for assistant in &main_table.assistants {
        write_main_table_content_row(
            sheet,
            position_y,
            number,
            &assistant.last_name,
            &assistant.middle_name,
            &assistant.first_name,
            &assistant.rank,
            &assistant.rate_and_hours,
            false,
        );
        position_y += 3;
        number += 1;
    }
    write_main_table_content_row(
        sheet,
        position_y,
        0,
        "Всього за асистентами",
        "",
        "",
        "",
        &main_table.assistants_total,
        true,
    );
    position_y += 3;
    for part_timer in &main_table.part_timers {
        write_main_table_content_row(
            sheet,
            position_y,
            number,
            &part_timer.last_name,
            &part_timer.middle_name,
            &part_timer.first_name,
            &part_timer.rank,
            &part_timer.rate_and_hours,
            false,
        );
        position_y += 3;
        number += 1;
    }
    write_main_table_content_row(
        sheet,
        position_y,
        0,
        "Всього за сумісниками",
        "",
        "",
        "",
        &main_table.part_timers_total,
        true,
    );
    position_y += 3;
    write_main_table_content_row(
        sheet,
        position_y,
        0,
        "Разом по кафедрі",
        "",
        "",
        "",
        &main_table.total,
        true,
    );
}

fn write_main_table_content_row(
    sheet: &mut Worksheet,
    position_y: u32,
    number: u32,
    first_row_text: &str,
    second_row_text: &str,
    third_row_text: &str,
    rank_text: &str,
    content_row: &OutputMainRateAndHours,
    make_bold: bool,
) {
    let is_name_merged = second_row_text.is_empty() && third_row_text.is_empty();
    sheet.add_merge_cells(&format!("A{}:A{}", position_y, position_y + 2));
    if is_name_merged {
        sheet.add_merge_cells(&format!("B{}:B{}", position_y, position_y + 2));
    }
    sheet.add_merge_cells(&format!("C{}:C{}", position_y, position_y + 2));
    sheet.add_merge_cells(&format!("D{}:D{}", position_y, position_y + 2));

    let mut cell = create_cell(
        if number > 0 {
            format!("{}", number)
        } else {
            String::new()
        }
        .as_str(),
        (1, position_y),
    );
    cell_set_text_alignment(&mut cell, &TextAlignment::VerticalCenter);
    cell_set_text_alignment(&mut cell, &TextAlignment::HorizontalCenter);
    sheet.set_cell(cell);
    cell_set_hv_borders(sheet, 1, position_y, 3);

    if is_name_merged {
        let mut cell = create_cell(first_row_text, (2, position_y));
        cell_set_text_alignment(&mut cell, &TextAlignment::VerticalCenter);
        if make_bold {
            cell_set_text_style(&mut cell, &TextStyle::Bold);
        }
        sheet.set_cell(cell);
        cell_set_hv_borders(sheet, 2, position_y, 3);
    } else {
        let mut cell = create_cell(first_row_text, (2, position_y));
        cell_set_text_style(&mut cell, &TextStyle::BoldItalic);
        sheet.set_cell(cell);
        let mut cell = create_cell(second_row_text, (2, position_y + 1));
        cell_set_text_style(&mut cell, &TextStyle::Italic);
        sheet.set_cell(cell);
        let mut cell = create_cell(third_row_text, (2, position_y + 2));
        cell_set_text_style(&mut cell, &TextStyle::Italic);
        sheet.set_cell(cell);
        cell_set_hv_borders(sheet, 2, position_y, 3);
    }

    let mut cell = create_cell(rank_text, (3, position_y));
    cell_set_text_alignment(&mut cell, &TextAlignment::VerticalCenter);
    sheet.set_cell(cell);
    cell_set_hv_borders(sheet, 3, position_y, 3);

    let mut cell = create_cell_number(content_row.rate, (4, position_y), true);
    cell_set_text_alignment(&mut cell, &TextAlignment::VerticalCenter);
    cell_set_text_alignment(&mut cell, &TextAlignment::HorizontalCenter);
    if make_bold {
        cell_set_text_style(&mut cell, &TextStyle::Bold);
    }
    sheet.set_cell(cell);
    cell_set_hv_borders(sheet, 4, position_y, 3);

    let mut cell = create_cell("I семестр", (5, position_y));
    cell_set_text_alignment(&mut cell, &TextAlignment::VerticalCenter);
    if make_bold {
        cell_set_text_style(&mut cell, &TextStyle::Bold);
    }
    sheet.set_cell(cell);
    let mut cell = create_cell("II семестр", (5, position_y + 1));
    cell_set_text_alignment(&mut cell, &TextAlignment::VerticalCenter);
    if make_bold {
        cell_set_text_style(&mut cell, &TextStyle::Bold);
    }
    sheet.set_cell(cell);
    let mut cell = create_cell("Рік", (5, position_y + 2));
    cell_set_text_alignment(&mut cell, &TextAlignment::VerticalCenter);
    if make_bold {
        cell_set_text_style(&mut cell, &TextStyle::Bold);
    }
    sheet.set_cell(cell);
    cell_set_hv_borders(sheet, 5, position_y, 3);

    for i in 0..14 {
        let value_1 = workload_hours_by_index(&content_row.semester_1, i);
        if let Some(value_1) = value_1 {
            let mut cell = create_cell_number(value_1, (6 + i, position_y), true);
            cell_set_text_alignment(&mut cell, &TextAlignment::VerticalCenter);
            cell_set_text_alignment(&mut cell, &TextAlignment::HorizontalCenter);
            if make_bold {
                cell_set_text_style(&mut cell, &TextStyle::Bold);
            }
            sheet.set_cell(cell);
        }
        let value_2 = workload_hours_by_index(&content_row.semester_2, i);
        if let Some(value_2) = value_2 {
            let mut cell = create_cell_number(value_2, (6 + i, position_y + 1), true);
            cell_set_text_alignment(&mut cell, &TextAlignment::VerticalCenter);
            cell_set_text_alignment(&mut cell, &TextAlignment::HorizontalCenter);
            if make_bold {
                cell_set_text_style(&mut cell, &TextStyle::Bold);
            }
            sheet.set_cell(cell);
        }
        let value_3 = workload_hours_by_index(&content_row.year, i);
        if let Some(value_3) = value_3 {
            let mut cell = create_cell_number(value_3, (6 + i, position_y + 2), true);
            cell_set_text_alignment(&mut cell, &TextAlignment::VerticalCenter);
            cell_set_text_alignment(&mut cell, &TextAlignment::HorizontalCenter);
            if i == 13 {
                cell_set_text_style(&mut cell, &TextStyle::Bold);
                cell_set_color(&mut cell, "FFFF0000");
            } else if make_bold {
                cell_set_text_style(&mut cell, &TextStyle::Bold);
            }
            sheet.set_cell(cell);
        }

        cell_set_hv_borders(sheet, 6 + i, position_y, 3);
    }

    cell_set_right_border(
        sheet.get_cell_mut((19, position_y)),
        &BorderThickness::Medium,
    );

    cell_set_right_border(
        sheet.get_cell_mut((19, position_y + 1)),
        &BorderThickness::Medium,
    );

    cell_set_right_border(
        sheet.get_cell_mut((19, position_y + 2)),
        &BorderThickness::Medium,
    );
}

fn write_additional_table_header(sheet: &mut Worksheet, position_y: u32) {
    for c in "ABCDEFGHIJ".chars() {
        sheet.add_merge_cells(&format!("{c}{position_y}:{c}{}", position_y + 1));
    }
    sheet.add_merge_cells(&format!("K{position_y}:X{position_y}"));

    row_set_height(sheet, position_y + 1, 240.0);
    column_set_width(sheet, 1, 4.0);
    column_set_width(sheet, 2, 20.0);
    column_set_width(sheet, 3, 16.0);
    column_set_width(sheet, 4, 6.0);
    column_set_width(sheet, 5, 40.0);
    column_set_width(sheet, 6, 6.0);
    column_set_width(sheet, 7, 10.0);
    column_set_width(sheet, 8, 14.0);
    let narrow_row_width = 8.0;
    for i in 9..=24 {
        column_set_width(sheet, i, narrow_row_width);
    }

    let mut cell_n = create_cell("№ з/п", (1, position_y));
    cell_set_text_orientation(&mut cell_n, &TextOrientation::Vertical);
    cell_set_text_style(&mut cell_n, &TextStyle::Bold);
    cell_set_text_alignment(&mut cell_n, &TextAlignment::VerticalCenter);
    cell_set_text_alignment(&mut cell_n, &TextAlignment::HorizontalCenter);
    cell_set_all_borders(&mut cell_n, &BorderThickness::Medium);
    cell_set_all_borders(
        sheet.get_cell_mut((1, position_y + 1)),
        &BorderThickness::Medium,
    );
    sheet.set_cell(cell_n);

    let mut cell_name = create_cell("Прізвище, ім'я та по батькові (повністю)", (2, position_y));
    cell_set_text_style(&mut cell_name, &TextStyle::Bold);
    cell_set_text_alignment(&mut cell_name, &TextAlignment::VerticalCenter);
    cell_set_text_alignment(&mut cell_name, &TextAlignment::HorizontalCenter);
    cell_set_all_borders(&mut cell_name, &BorderThickness::Medium);
    cell_set_all_borders(
        sheet.get_cell_mut((2, position_y + 1)),
        &BorderThickness::Medium,
    );
    sheet.set_cell(cell_name);

    let mut cell_rank = create_cell("Посада, вчене звання, вчена ступінь", (3, position_y));
    cell_set_text_style(&mut cell_rank, &TextStyle::Bold);
    cell_set_text_alignment(&mut cell_rank, &TextAlignment::VerticalCenter);
    cell_set_text_alignment(&mut cell_rank, &TextAlignment::HorizontalCenter);
    cell_set_all_borders(&mut cell_rank, &BorderThickness::Medium);
    cell_set_all_borders(
        sheet.get_cell_mut((3, position_y + 1)),
        &BorderThickness::Medium,
    );
    sheet.set_cell(cell_rank);

    let mut cell_rate = create_cell("Ставка", (4, position_y));
    cell_set_text_orientation(&mut cell_rate, &TextOrientation::Vertical);
    cell_set_text_style(&mut cell_rate, &TextStyle::Bold);
    cell_set_text_alignment(&mut cell_rate, &TextAlignment::VerticalCenter);
    cell_set_text_alignment(&mut cell_rate, &TextAlignment::HorizontalCenter);
    cell_set_all_borders(&mut cell_rate, &BorderThickness::Medium);
    cell_set_all_borders(
        sheet.get_cell_mut((4, position_y + 1)),
        &BorderThickness::Medium,
    );
    sheet.set_cell(cell_rate);

    let mut cell_discipline_name = create_cell("Назва дисципліни", (5, position_y));
    cell_set_text_style(&mut cell_discipline_name, &TextStyle::Bold);
    cell_set_text_alignment(&mut cell_discipline_name, &TextAlignment::VerticalCenter);
    cell_set_text_alignment(&mut cell_discipline_name, &TextAlignment::HorizontalCenter);
    cell_set_all_borders(&mut cell_discipline_name, &BorderThickness::Medium);
    cell_set_all_borders(
        sheet.get_cell_mut((5, position_y + 1)),
        &BorderThickness::Medium,
    );
    sheet.set_cell(cell_discipline_name);

    let some_header_texts = vec![
        "Форма навчання",
        "Спеціальність",
        "Група",
        "Курс",
        "Контингент",
    ];

    let mut x = 6;
    for header_text in some_header_texts {
        let mut cell_workload_type = create_cell(header_text, (x, position_y));
        cell_set_text_orientation(&mut cell_workload_type, &TextOrientation::Vertical);
        cell_set_text_style(&mut cell_workload_type, &TextStyle::Bold);
        cell_set_text_alignment(&mut cell_workload_type, &TextAlignment::VerticalCenter);
        cell_set_text_alignment(&mut cell_workload_type, &TextAlignment::HorizontalCenter);
        cell_set_all_borders(&mut cell_workload_type, &BorderThickness::Medium);
        cell_set_all_borders(
            sheet.get_cell_mut((x, position_y + 1)),
            &BorderThickness::Medium,
        );
        sheet.set_cell(cell_workload_type);
        x += 1;
    }

    let mut cell_types_of_workload = create_cell("ВИДИ НАВЧАЛЬНОГО НАВАНТАЖЕННЯ", (11, position_y));
    cell_set_text_style(&mut cell_types_of_workload, &TextStyle::Bold);
    cell_set_text_alignment(&mut cell_types_of_workload, &TextAlignment::VerticalCenter);
    cell_set_text_alignment(
        &mut cell_types_of_workload,
        &TextAlignment::HorizontalCenter,
    );
    cell_set_all_borders(&mut cell_types_of_workload, &BorderThickness::Medium);
    for i in 7..=24 {
        cell_set_all_borders(
            sheet.get_cell_mut((i, position_y)),
            &BorderThickness::Medium,
        );
    }
    sheet.set_cell(cell_types_of_workload);

    let workload_types = vec![
        "Лекції",
        "Практичні (семінарські) заняття",
        "Лабораторні роботи",
        "Екзамени",
        "Консультації перед екзаменами",
        "Заліки",
        "Випускні кваліфікаційні роботи",
        "Виробнича практика",
        "Навчальна практика",
        "Поточні консультації",
        "Індивідуальні",
        "Курсові роботи",
        "Керівництво аспірантами",
        "Всього",
    ];

    let mut x = 11;
    for wl_type in workload_types {
        let mut cell_workload_type = create_cell(wl_type, (x, position_y + 1));
        cell_set_text_orientation(&mut cell_workload_type, &TextOrientation::Vertical);
        cell_set_text_style(&mut cell_workload_type, &TextStyle::Bold);
        cell_set_text_alignment(&mut cell_workload_type, &TextAlignment::VerticalCenter);
        cell_set_text_alignment(&mut cell_workload_type, &TextAlignment::HorizontalCenter);
        cell_set_all_borders(&mut cell_workload_type, &BorderThickness::Medium);
        sheet.set_cell(cell_workload_type);
        x += 1;
    }
}

fn write_additional_table_content(
    sheet: &mut Worksheet,
    position_y: u32,
    table: &OutputPersonalTable,
) -> u32 {
    let mut table_start_y = position_y + 1;
    let mut table_height: u32 = 2;
    for i in 0..2 {
        let semester = if i == 0 {
            &table.semester_1
        } else {
            &table.semester_2
        };
        let comment = if i == 0 {
            &table.comment_semester_1
        } else {
            &table.comment_semester_2
        };
        let semester_rate = if i == 0 {
            &table.semester_1_rate
        } else {
            &table.semester_2_rate
        };
        let semester_total_day = if i == 0 {
            &table.semester_1_total_day
        } else {
            &table.semester_2_total_day
        };
        let semester_total_evening = if i == 0 {
            &table.semester_1_total_evening
        } else {
            &table.semester_2_total_evening
        };
        let semester_total = if i == 0 {
            &table.semester_1_total
        } else {
            &table.semester_2_total
        };

        sheet.add_merge_cells(&format!("A{}:X{}", table_start_y - 1, table_start_y - 1));
        let mut cell = create_cell(
            &format!("{} семестр", if i == 0 { "I" } else { "II" }),
            (1, table_start_y - 1),
        );
        cell_set_text_style(&mut cell, &TextStyle::Bold);
        cell_set_text_alignment(&mut cell, &TextAlignment::HorizontalCenter);
        cell_set_all_borders(&mut cell, &BorderThickness::Medium);
        for i in 1..=24 {
            cell_set_all_borders(
                sheet.get_cell_mut((i, table_start_y - 1)),
                &BorderThickness::Medium,
            );
        }
        sheet.set_cell(cell);

        let table_half_height = semester.len() as u32 + if i == 0 { 4 } else { 5 };

        sheet.add_merge_cells(&format!(
            "A{table_start_y}:A{}",
            table_start_y + table_half_height
        ));
        sheet.add_merge_cells(&format!(
            "B{}:B{}",
            table_start_y + 3,
            table_start_y + table_half_height
        ));
        sheet.add_merge_cells(&format!(
            "C{table_start_y}:C{}",
            table_start_y + table_half_height
        ));
        sheet.add_merge_cells(&format!(
            "D{table_start_y}:D{}",
            table_start_y + table_half_height
        ));

        let mut cell = create_cell(&format!("{}", table.id), (1, table_start_y));
        cell_set_text_alignment(&mut cell, &TextAlignment::HorizontalCenter);
        cell_set_text_alignment(&mut cell, &TextAlignment::VerticalCenter);
        sheet.set_cell(cell);

        let mut cell = create_cell(&table.last_name, (2, table_start_y));
        cell_set_text_style(&mut cell, &TextStyle::BoldItalic);
        sheet.set_cell(cell);

        let mut cell = create_cell(&table.middle_name, (2, table_start_y + 1));
        cell_set_text_style(&mut cell, &TextStyle::Italic);
        sheet.set_cell(cell);

        let mut cell = create_cell(&table.first_name, (2, table_start_y + 2));
        cell_set_text_style(&mut cell, &TextStyle::Italic);
        sheet.set_cell(cell);

        let mut cell = create_cell(&comment, (2, table_start_y + 3));
        cell_set_text_style(&mut cell, &TextStyle::BoldItalic);
        cell_set_text_alignment(&mut cell, &TextAlignment::Top);
        sheet.set_cell(cell);

        let mut cell = create_cell(&table.rank, (3, table_start_y));
        cell_set_text_alignment(&mut cell, &TextAlignment::Top);
        sheet.set_cell(cell);

        let mut cell = create_cell_number(*semester_rate, (4, table_start_y), true);
        cell_set_text_orientation(&mut cell, &TextOrientation::Vertical);
        cell_set_text_alignment(&mut cell, &TextAlignment::HorizontalCenter);
        cell_set_text_alignment(&mut cell, &TextAlignment::VerticalCenter);
        sheet.set_cell(cell);

        let mut temp_y = table_start_y;
        for row in semester {
            let students_count = format!("{}", row.students_count);
            write_additional_content_row(
                sheet,
                temp_y,
                &row.hours,
                &row.name,
                Some(&row.learning_form),
                Some(&row.speciality),
                Some(&row.group),
                Some(&row.course),
                Some(&students_count),
                row.merge_lectures_with_next,
            );
            temp_y += 1;
        }
        additional_content_fill_empty_borders(sheet, temp_y);
        temp_y += 1;
        write_additional_content_row(
            sheet,
            temp_y,
            semester_total_day,
            "Разом (денна форма)",
            None,
            None,
            None,
            None,
            None,
            false,
        );
        temp_y += 1;
        additional_content_fill_empty_borders(sheet, temp_y);
        temp_y += 1;
        write_additional_content_row(
            sheet,
            temp_y,
            semester_total_evening,
            "Разом (вечірня форма)",
            None,
            None,
            None,
            None,
            None,
            false,
        );
        temp_y += 1;
        write_additional_content_row(
            sheet,
            temp_y,
            semester_total,
            &format!("Усього за {} семестр", if i == 0 { 1 } else { 2 }),
            None,
            None,
            None,
            None,
            None,
            false,
        );
        temp_y += 1;
        if i == 1 {
            write_additional_content_row(
                sheet,
                temp_y,
                &table.year_total,
                "Усього за рік",
                None,
                None,
                None,
                None,
                None,
                false,
            );
        }

        for i in 1..=4 {
            cell_set_hv_borders(sheet, i, table_start_y, table_half_height + 1);
        }

        for i in 0..=table_half_height {
            let cell = sheet.get_cell_mut((24, table_start_y + i));
            cell_set_right_border(cell, &BorderThickness::Medium);
        }
        table_start_y += table_half_height + 2;
        table_height += table_half_height + 1;
    }
    table_height
}

fn write_additional_content_row(
    sheet: &mut Worksheet,
    y: u32,
    hours: &OutputHoursRow,
    name: &str,
    learning_form: Option<&str>,
    speciality: Option<&str>,
    group: Option<&str>,
    course: Option<&str>,
    students_count: Option<&str>,
    merge_lectures: bool,
) {
    let name_overriden = learning_form.is_none()
        || speciality.is_none()
        || group.is_none()
        || course.is_none()
        || students_count.is_none();
    let border_t = if name_overriden {
        BorderThickness::Medium
    } else {
        BorderThickness::Thin
    };
    if merge_lectures {
        sheet.add_merge_cells(&format!("K{}:K{}", y, y + 1));
    }
    if name_overriden {
        let mut cell = create_cell(name, (5, y));
        cell_set_text_style(&mut cell, &TextStyle::BoldItalic);
        cell_set_top_border(&mut cell, &BorderThickness::Medium);
        cell_set_bottom_border(&mut cell, &BorderThickness::Medium);
        cell_set_left_border(&mut cell, &BorderThickness::Medium);
        sheet.set_cell(cell);
        for i in 1..=5 {
            let cell = sheet.get_cell_mut((5 + i, y));
            cell_set_top_border(cell, &BorderThickness::Medium);
            cell_set_bottom_border(cell, &BorderThickness::Medium);
            cell_set_left_border(cell, &BorderThickness::Thin);
            cell_set_right_border(cell, &BorderThickness::Thin);
        }
    } else {
        for i in 0..=5 {
            let value = match i {
                0 => name,
                1 => learning_form.unwrap_or(""),
                2 => speciality.unwrap_or(""),
                3 => group.unwrap_or(""),
                4 => course.unwrap_or(""),
                5 => students_count.unwrap_or(""),
                _ => "",
            };
            let mut cell = create_cell(value, (5 + i, y));
            cell_set_top_border(&mut cell, &border_t);
            cell_set_bottom_border(&mut cell, &border_t);
            cell_set_left_border(&mut cell, &BorderThickness::Thin);
            cell_set_right_border(&mut cell, &BorderThickness::Thin);
            if i == 0 {
                cell_set_left_border(&mut cell, &border_t);
            } else {
                cell_set_text_alignment(&mut cell, &TextAlignment::HorizontalCenter);
            }
            sheet.set_cell(cell);
        }
    }
    for i in 0..=13 {
        let value = workload_hours_by_index(hours, i);
        if let Some(value) = value {
            let cell = create_cell_number(value, (11 + i, y), true);
            sheet.set_cell(cell);
        };
        let cell = sheet.get_cell_mut((11 + i, y));
        if name_overriden {
            cell_set_text_style(cell, &TextStyle::BoldItalic);
        }
        cell_set_text_alignment(cell, &TextAlignment::HorizontalCenter);
        cell_set_top_border(cell, &border_t);
        cell_set_bottom_border(cell, &border_t);
        cell_set_left_border(
            cell,
            if i == 0 {
                &BorderThickness::Medium
            } else {
                &BorderThickness::Thin
            },
        );
        cell_set_right_border(cell, &BorderThickness::Thin);
        if i == 13 {
            cell_set_all_borders(cell, &BorderThickness::Medium);
            cell_set_text_style(cell, &TextStyle::Bold);
        }
        if i == 0 && merge_lectures {
            cell_set_text_alignment(cell, &TextAlignment::VerticalCenter);
        }
    }
}

fn additional_content_fill_empty_borders(sheet: &mut Worksheet, y: u32) {
    for i in 5..=24 {
        let cell = sheet.get_cell_mut((i, y));
        cell_set_all_borders(cell, &BorderThickness::Thin);
        if i == 11 {
            cell_set_left_border(cell, &BorderThickness::Medium);
        }
    }
}

fn cell_set_hv_borders(sheet: &mut Worksheet, x: u32, y: u32, height: u32) {
    for i in 0..height {
        let cell = sheet.get_cell_mut((x, y + i));
        if i == 0 {
            cell_set_top_border(cell, &BorderThickness::Medium);
        }
        if i == (height - 1) {
            cell_set_bottom_border(cell, &BorderThickness::Medium);
        }
        cell_set_left_border(cell, &BorderThickness::Thin);
        cell_set_right_border(cell, &BorderThickness::Thin);
    }
}

fn workload_hours_by_index(hours: &OutputHoursRow, index: u32) -> Option<f64> {
    let value = match index {
        0 => hours.lectures,
        1 => hours.practices,
        2 => hours.labs,
        3 => hours.exams,
        4 => hours.exam_consults,
        5 => hours.tests,
        6 => hours.qual_works,
        7 => hours.working_practice,
        8 => hours.teaching_practice,
        9 => hours.consults,
        10 => hours.individual_works,
        11 => hours.course_works,
        12 => hours.supervising,
        13 => hours.total,
        _ => -1_f64,
    };
    if value < 0_f64 { None } else { Some(value) }
}

pub fn get_test_output_data() -> ExportedData {
    ExportedData {
        year: 2024,
        type_name: "електронних обчислювальних машин (КЕО)".to_string(),
        main_table: OutputMainTable {
            heads: vec![OutputMainWorkerRow {
                first_name: "Володимир".to_string(),
                middle_name: "Сергійович".to_string(),
                last_name: "Хандецький".to_string(),
                rank: "зав. каф., д.т.н., професор, Гарант ОПП PhD".to_string(),
                rate_and_hours: OutputMainRateAndHours {
                    rate: 1.00_f64,
                    semester_1: OutputHoursRow::new(
                        56.00_f64, -1_f64, 96.00_f64, 13.00_f64, 4.00_f64, -1_f64, 30.00_f64,
                        6.67_f64, -1_f64, 11.00_f64, -1_f64, 176.00_f64, -1_f64, 392.67_f64,
                    ),
                    semester_2: OutputHoursRow::new(
                        60.00_f64, -1_f64, 36.00_f64, -1_f64, -1_f64, -1_f64, 45.00_f64, 12.00_f64,
                        -1_f64, 3.00_f64, -1_f64, 30.00_f64, -1_f64, 196.00_f64,
                    ),
                    year: OutputHoursRow::new(
                        116.00_f64, -1_f64, 132.00_f64, 13.00_f64, 4.00_f64, -1_f64, 75.00_f64,
                        18.67_f64, -1_f64, 14.00_f64, -1_f64, 206.00_f64, -1_f64, 578.67_f64,
                    ),
                },
            }],
            heads_total: OutputMainRateAndHours {
                rate: 1.00_f64,
                semester_1: OutputHoursRow::new(
                    56.00_f64, -1_f64, 96.00_f64, 13.00_f64, 4.00_f64, -1_f64, 30.00_f64, 6.67_f64,
                    -1_f64, 11.00_f64, -1_f64, 176.00_f64, -1_f64, 392.67_f64,
                ),
                semester_2: OutputHoursRow::new(
                    60.00_f64, -1_f64, 36.00_f64, -1_f64, -1_f64, -1_f64, 45.00_f64, 12.00_f64,
                    -1_f64, 3.00_f64, -1_f64, 30.00_f64, -1_f64, 196.00_f64,
                ),
                year: OutputHoursRow::new(
                    116.00_f64, -1_f64, 132.00_f64, 13.00_f64, 4.00_f64, -1_f64, 75.00_f64,
                    18.67_f64, -1_f64, 14.00_f64, -1_f64, 206.00_f64, -1_f64, 578.67_f64,
                ),
            },
            professors: vec![OutputMainWorkerRow {
                first_name: "Олександр".to_string(),
                middle_name: "Сергійович".to_string(),
                last_name: "Тонкошкур".to_string(),
                rank: "Професор професор д.ф.м.н.".to_string(),
                rate_and_hours: OutputMainRateAndHours {
                    rate: 1.00_f64,
                    semester_1: OutputHoursRow::new(
                        48.00_f64, -1_f64, 112.00_f64, 23.90_f64, 6.00_f64, -1_f64, 30.00_f64,
                        6.67_f64, -1_f64, 10.00_f64, -1_f64, -1_f64, -1_f64, 236.57_f64,
                    ),
                    semester_2: OutputHoursRow::new(
                        110.00_f64, -1_f64, 194.00_f64, 10.00_f64, 2.00_f64, -1_f64, 15.00_f64,
                        10.00_f64, -1_f64, 13.00_f64, -1_f64, -1_f64, -1_f64, 354.00_f64,
                    ),
                    year: OutputHoursRow::new(
                        158.00_f64, -1_f64, 306.00_f64, 33.90_f64, 8.00_f64, -1_f64, 45.00_f64,
                        16.67_f64, -1_f64, 23.00_f64, -1_f64, -1_f64, -1_f64, 590.57_f64,
                    ),
                },
            }],
            professors_total: OutputMainRateAndHours {
                rate: 1.00_f64,
                semester_1: OutputHoursRow::new(
                    48.00_f64, -1_f64, 112.00_f64, 23.90_f64, 6.00_f64, -1_f64, 30.00_f64,
                    6.67_f64, -1_f64, 10.00_f64, -1_f64, -1_f64, -1_f64, 236.57_f64,
                ),
                semester_2: OutputHoursRow::new(
                    110.00_f64, -1_f64, 194.00_f64, 10.00_f64, 2.00_f64, -1_f64, 15.00_f64,
                    10.00_f64, -1_f64, 13.00_f64, -1_f64, -1_f64, -1_f64, 354.00_f64,
                ),
                year: OutputHoursRow::new(
                    158.00_f64, -1_f64, 306.00_f64, 33.90_f64, 8.00_f64, -1_f64, 45.00_f64,
                    16.67_f64, -1_f64, 23.00_f64, -1_f64, -1_f64, -1_f64, 590.57_f64,
                ),
            },
            associate_professors: vec![
                OutputMainWorkerRow {
                    first_name: "Олексій".to_string(),
                    middle_name: "Борисович".to_string(),
                    last_name: "Гниленко".to_string(),
                    rank: "Доцент доцент к.ф.м.н.".to_string(),
                    rate_and_hours: OutputMainRateAndHours {
                        rate: 1.00_f64,
                        semester_1: OutputHoursRow::new(
                            84.00_f64, 80.00_f64, 50.00_f64, 13.00_f64, 4.00_f64, -1_f64,
                            21.00_f64, 6.67_f64, -1_f64, 13.00_f64, -1_f64, -1_f64, -1_f64,
                            271.67_f64,
                        ),
                        semester_2: OutputHoursRow::new(
                            76.00_f64, 16.00_f64, 164.00_f64, 26.00_f64, 7.00_f64, -1_f64,
                            9.00_f64, 6.00_f64, -1_f64, 19.00_f64, -1_f64, -1_f64, -1_f64,
                            323.00_f64,
                        ),
                        year: OutputHoursRow::new(
                            160.00_f64, 96.00_f64, 214.00_f64, 39.00_f64, 11.00_f64, -1_f64,
                            30.00_f64, 12.67_f64, -1_f64, 32.00_f64, -1_f64, -1_f64, -1_f64,
                            594.67_f64,
                        ),
                    },
                },
                OutputMainWorkerRow {
                    first_name: "Надія".to_string(),
                    middle_name: "Валеріївна".to_string(),
                    last_name: "Карпенко".to_string(),
                    rank: "Доцент к.ф.м.н.".to_string(),
                    rate_and_hours: OutputMainRateAndHours {
                        rate: 1.00_f64,
                        semester_1: OutputHoursRow::new(
                            82.00_f64, -1_f64, 142.00_f64, 10.00_f64, 3.00_f64, -1_f64, 21.00_f64,
                            6.67_f64, -1_f64, 12.00_f64, -1_f64, 8.00_f64, -1_f64, 284.67_f64,
                        ),
                        semester_2: OutputHoursRow::new(
                            60.00_f64, -1_f64, 180.00_f64, 7.00_f64, 2.00_f64, -1_f64, 18.00_f64,
                            12.00_f64, -1_f64, 16.00_f64, -1_f64, 15.00_f64, -1_f64, 310.00_f64,
                        ),
                        year: OutputHoursRow::new(
                            142.00_f64, -1_f64, 322.00_f64, 17.00_f64, 5.00_f64, -1_f64, 39.00_f64,
                            18.67_f64, -1_f64, 28.00_f64, -1_f64, 23.00_f64, -1_f64, 594.67_f64,
                        ),
                    },
                },
                OutputMainWorkerRow {
                    first_name: "Олександр".to_string(),
                    middle_name: "Анатолійович".to_string(),
                    last_name: "Литвинов".to_string(),
                    rank: "Доцент доцент к.т.н. Гарант ОПП бакалавр".to_string(),
                    rate_and_hours: OutputMainRateAndHours {
                        rate: 1.00_f64,
                        semester_1: OutputHoursRow::new(
                            24.00_f64, -1_f64, 32.00_f64, 1.20_f64, -1_f64, -1_f64, 30.00_f64,
                            6.67_f64, -1_f64, 4.00_f64, -1_f64, 16.00_f64, -1_f64, 113.87_f64,
                        ),
                        semester_2: OutputHoursRow::new(
                            120.00_f64, -1_f64, 136.00_f64, 19.00_f64, 6.00_f64, -1_f64, 45.00_f64,
                            12.00_f64, -1_f64, 15.00_f64, -1_f64, 124.00_f64, -1_f64, 477.00_f64,
                        ),
                        year: OutputHoursRow::new(
                            144.00_f64, -1_f64, 168.00_f64, 20.20_f64, 6.00_f64, -1_f64, 75.00_f64,
                            18.67_f64, -1_f64, 19.00_f64, -1_f64, 140.00_f64, -1_f64, 590.87_f64,
                        ),
                    },
                },
                OutputMainWorkerRow {
                    first_name: "Наталія".to_string(),
                    middle_name: "Олександрівна".to_string(),
                    last_name: "Матвеєва".to_string(),
                    rank: "Доцент доцент к.т.н.".to_string(),
                    rate_and_hours: OutputMainRateAndHours {
                        rate: 1.00_f64,
                        semester_1: OutputHoursRow::new(
                            60.00_f64, -1_f64, 104.00_f64, 0.90_f64, -1_f64, -1_f64, 21.00_f64,
                            6.67_f64, -1_f64, 10.00_f64, -1_f64, 28.00_f64, -1_f64, 230.57_f64,
                        ),
                        semester_2: OutputHoursRow::new(
                            44.00_f64, -1_f64, 188.00_f64, 7.00_f64, 2.00_f64, -1_f64, 44.00_f64,
                            12.00_f64, -1_f64, 16.00_f64, -1_f64, 54.00_f64, -1_f64, 367.00_f64,
                        ),
                        year: OutputHoursRow::new(
                            104.00_f64, -1_f64, 292.00_f64, 7.90_f64, 2.00_f64, -1_f64, 65.00_f64,
                            18.67_f64, -1_f64, 26.00_f64, -1_f64, 82.00_f64, -1_f64, 597.57_f64,
                        ),
                    },
                },
                OutputMainWorkerRow {
                    first_name: "Ігор".to_string(),
                    middle_name: "Володимирович".to_string(),
                    last_name: "Пономарьов".to_string(),
                    rank: "Доцент доцент к.т.н.".to_string(),
                    rate_and_hours: OutputMainRateAndHours {
                        rate: 1.00_f64,
                        semester_1: OutputHoursRow::new(
                            60.00_f64, -1_f64, 180.00_f64, 13.00_f64, 3.00_f64, -1_f64, 21.00_f64,
                            6.67_f64, -1_f64, 15.00_f64, -1_f64, 20.00_f64, -1_f64, 318.67_f64,
                        ),
                        semester_2: OutputHoursRow::new(
                            60.00_f64, 58.00_f64, 100.00_f64, -1_f64, -1_f64, -1_f64, 15.00_f64,
                            10.00_f64, -1_f64, 5.00_f64, -1_f64, 30.00_f64, -1_f64, 278.00_f64,
                        ),
                        year: OutputHoursRow::new(
                            120.00_f64, 58.00_f64, 280.00_f64, 13.00_f64, 3.00_f64, -1_f64,
                            36.00_f64, 16.67_f64, -1_f64, 20.00_f64, -1_f64, 50.00_f64, -1_f64,
                            596.67_f64,
                        ),
                    },
                },
                OutputMainWorkerRow {
                    first_name: "Ігор".to_string(),
                    middle_name: "Анатолійович".to_string(),
                    last_name: "Скуратовський".to_string(),
                    rank: "Доцент доцент к.ф.м.н.".to_string(),
                    rate_and_hours: OutputMainRateAndHours {
                        rate: 1.00_f64,
                        semester_1: OutputHoursRow::new(
                            112.00_f64, -1_f64, 196.00_f64, -1_f64, -1_f64, -1_f64, 21.00_f64,
                            6.67_f64, -1_f64, 11.00_f64, -1_f64, -1_f64, -1_f64, 346.67_f64,
                        ),
                        semester_2: OutputHoursRow::new(
                            88.00_f64, -1_f64, 120.00_f64, -1_f64, -1_f64, -1_f64, 15.00_f64,
                            10.00_f64, -1_f64, 5.00_f64, -1_f64, 12.00_f64, -1_f64, 250.00_f64,
                        ),
                        year: OutputHoursRow::new(
                            200.00_f64, -1_f64, 316.00_f64, -1_f64, -1_f64, -1_f64, 36.00_f64,
                            16.67_f64, -1_f64, 16.00_f64, -1_f64, 12.00_f64, -1_f64, 596.67_f64,
                        ),
                    },
                },
                OutputMainWorkerRow {
                    first_name: "Ольга".to_string(),
                    middle_name: "Володимирівна".to_string(),
                    last_name: "Спірінцева".to_string(),
                    rank: "Доцент к.т.н.".to_string(),
                    rate_and_hours: OutputMainRateAndHours {
                        rate: 1.00_f64,
                        semester_1: OutputHoursRow::new(
                            82.00_f64, 40.00_f64, 128.00_f64, 21.00_f64, 6.00_f64, -1_f64,
                            21.00_f64, 6.67_f64, -1_f64, 16.00_f64, -1_f64, -1_f64, -1_f64,
                            320.67_f64,
                        ),
                        semester_2: OutputHoursRow::new(
                            44.00_f64, -1_f64, 120.00_f64, 13.00_f64, 4.00_f64, -1_f64, 15.00_f64,
                            10.00_f64, 40.00_f64, 5.00_f64, -1_f64, 24.00_f64, -1_f64, 275.00_f64,
                        ),
                        year: OutputHoursRow::new(
                            126.00_f64, 40.00_f64, 248.00_f64, 34.00_f64, 10.00_f64, -1_f64,
                            36.00_f64, 16.67_f64, 40.00_f64, 21.00_f64, -1_f64, 24.00_f64, -1_f64,
                            595.67_f64,
                        ),
                    },
                },
                OutputMainWorkerRow {
                    first_name: "Микола".to_string(),
                    middle_name: "Іванович".to_string(),
                    last_name: "Твердоступ".to_string(),
                    rank: "Доцент доцент к.т.н.".to_string(),
                    rate_and_hours: OutputMainRateAndHours {
                        rate: 0.90_f64,
                        semester_1: OutputHoursRow::new(
                            68.00_f64, 80.00_f64, -1_f64, 23.00_f64, 5.00_f64, -1_f64, -1_f64,
                            3.33_f64, -1_f64, 9.00_f64, -1_f64, 196.00_f64, -1_f64, 384.33_f64,
                        ),
                        semester_2: OutputHoursRow::new(
                            52.00_f64, -1_f64, 64.00_f64, 20.00_f64, 5.00_f64, -1_f64, 6.00_f64,
                            4.00_f64, -1_f64, 4.00_f64, -1_f64, -1_f64, -1_f64, 155.00_f64,
                        ),
                        year: OutputHoursRow::new(
                            120.00_f64, 80.00_f64, 64.00_f64, 43.00_f64, 10.00_f64, -1_f64,
                            6.00_f64, 7.33_f64, -1_f64, 13.00_f64, -1_f64, 196.00_f64, -1_f64,
                            539.33_f64,
                        ),
                    },
                },
            ],
            associate_professors_total: OutputMainRateAndHours {
                rate: 7.90_f64,
                semester_1: OutputHoursRow::new(
                    572.00_f64,
                    200.00_f64,
                    832.00_f64,
                    82.10_f64,
                    21.00_f64,
                    -1_f64,
                    156.00_f64,
                    50.02_f64,
                    -1_f64,
                    90.00_f64,
                    -1_f64,
                    268.00_f64,
                    -1_f64,
                    2271.12_f64,
                ),
                semester_2: OutputHoursRow::new(
                    544.00_f64,
                    74.00_f64,
                    1072.00_f64,
                    92.00_f64,
                    26.00_f64,
                    -1_f64,
                    167.00_f64,
                    76.00_f64,
                    40.00_f64,
                    85.00_f64,
                    -1_f64,
                    527.00_f64,
                    -1_f64,
                    4706.12_f64,
                ),
                year: OutputHoursRow::new(
                    1116.00_f64,
                    274.00_f64,
                    1904.00_f64,
                    174.10_f64,
                    47.00_f64,
                    -1_f64,
                    323.00_f64,
                    126.02_f64,
                    40.00_f64,
                    175.00_f64,
                    -1_f64,
                    527.00_f64,
                    -1_f64,
                    4706.12_f64,
                ),
            },
            lecturers: vec![OutputMainWorkerRow {
                first_name: "Геннадій".to_string(),
                middle_name: "Володимирович".to_string(),
                last_name: "Полухін".to_string(),
                rank: "з 07.10.24 Старший викладач".to_string(),
                rate_and_hours: OutputMainRateAndHours {
                    rate: 1.00_f64,
                    semester_1: OutputHoursRow::new(
                        28.00_f64, -1_f64, 184.00_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64,
                        -1_f64, 4.00_f64, -1_f64, -1_f64, -1_f64, 216.00_f64,
                    ),
                    semester_2: OutputHoursRow::new(
                        60.00_f64, -1_f64, 184.00_f64, 7.00_f64, 2.00_f64, -1_f64, -1_f64, -1_f64,
                        -1_f64, 10.00_f64, -1_f64, 44.00_f64, -1_f64, 307.00_f64,
                    ),
                    year: OutputHoursRow::new(
                        88.00_f64, -1_f64, 368.00_f64, 7.00_f64, 2.00_f64, -1_f64, -1_f64, -1_f64,
                        -1_f64, 14.00_f64, -1_f64, 44.00_f64, -1_f64, 523.00_f64,
                    ),
                },
            }],
            lecturers_total: OutputMainRateAndHours {
                rate: 1.00_f64,
                semester_1: OutputHoursRow::new(
                    28.00_f64, -1_f64, 184.00_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64,
                    4.00_f64, -1_f64, -1_f64, -1_f64, 216.00_f64,
                ),
                semester_2: OutputHoursRow::new(
                    60.00_f64, -1_f64, 184.00_f64, 7.00_f64, 2.00_f64, -1_f64, -1_f64, -1_f64,
                    -1_f64, 10.00_f64, -1_f64, 44.00_f64, -1_f64, 307.00_f64,
                ),
                year: OutputHoursRow::new(
                    88.00_f64, -1_f64, 368.00_f64, 7.00_f64, 2.00_f64, -1_f64, -1_f64, -1_f64,
                    -1_f64, 14.00_f64, -1_f64, 44.00_f64, -1_f64, 523.00_f64,
                ),
            },
            assistants: vec![
                OutputMainWorkerRow {
                    first_name: "Станіслав".to_string(),
                    middle_name: "Васильович".to_string(),
                    last_name: "Мазурик".to_string(),
                    rank: "Асистент".to_string(),
                    rate_and_hours: OutputMainRateAndHours {
                        rate: 0.90_f64,
                        semester_1: OutputHoursRow::new(
                            -1_f64, -1_f64, 344.00_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64,
                            -1_f64, 17.00_f64, -1_f64, -1_f64, -1_f64, 361.00_f64,
                        ),
                        semester_2: OutputHoursRow::new(
                            -1_f64, -1_f64, 116.00_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64,
                            40.00_f64, 4.00_f64, -1_f64, 16.00_f64, -1_f64, 176.00_f64,
                        ),
                        year: OutputHoursRow::new(
                            -1_f64, -1_f64, 460.00_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64,
                            40.00_f64, 21.00_f64, -1_f64, 16.00_f64, -1_f64, 537.00_f64,
                        ),
                    },
                },
                OutputMainWorkerRow {
                    first_name: "Михайло".to_string(),
                    middle_name: "Олександрович".to_string(),
                    last_name: "Литвинов".to_string(),
                    rank: "Асистент з 30.09".to_string(),
                    rate_and_hours: OutputMainRateAndHours {
                        rate: 0.60_f64,
                        semester_1: OutputHoursRow::new(
                            -1_f64, -1_f64, 94.00_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64,
                            -1_f64, -1_f64, -1_f64, 48.00_f64, -1_f64, 142.00_f64,
                        ),
                        semester_2: OutputHoursRow::new(
                            -1_f64, 48.00_f64, 108.00_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64,
                            18.00_f64, 4.00_f64, -1_f64, -1_f64, -1_f64, 178.00_f64,
                        ),
                        year: OutputHoursRow::new(
                            -1_f64, 48.00_f64, 202.00_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64,
                            18.00_f64, 4.00_f64, -1_f64, 48.00_f64, -1_f64, 857.00_f64,
                        ),
                    },
                },
            ],
            assistants_total: OutputMainRateAndHours {
                rate: 1.50_f64,
                semester_1: OutputHoursRow::new(
                    -1_f64, -1_f64, 438.00_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64,
                    17.00_f64, -1_f64, 48.00_f64, -1_f64, 503.00_f64,
                ),
                semester_2: OutputHoursRow::new(
                    -1_f64, 48.00_f64, 224.00_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64,
                    58.00_f64, 8.00_f64, -1_f64, 16.00_f64, -1_f64, 354.00_f64,
                ),
                year: OutputHoursRow::new(
                    -1_f64, 48.00_f64, 224.00_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64,
                    58.00_f64, 25.00_f64, -1_f64, 64.00_f64, -1_f64, 857.00_f64,
                ),
            },
            part_timers: vec![OutputMainWorkerRow {
                first_name: "Станіслав".to_string(),
                middle_name: "Васильович".to_string(),
                last_name: "Мазурик".to_string(),
                rank: "Асистент з 07.10.24".to_string(),
                rate_and_hours: OutputMainRateAndHours {
                    rate: 0.10_f64,
                    semester_1: OutputHoursRow::new(
                        -1_f64, -1_f64, 12.00_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64,
                        -1_f64, -1_f64, -1_f64, -1_f64, 12.00_f64,
                    ),
                    semester_2: OutputHoursRow::new(
                        -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64,
                        -1_f64, -1_f64, 40.00_f64, -1_f64, 40.00_f64,
                    ),
                    year: OutputHoursRow::new(
                        -1_f64, -1_f64, 12.00_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64,
                        -1_f64, -1_f64, 40.00_f64, -1_f64, 52.00_f64,
                    ),
                },
            }],
            part_timers_total: OutputMainRateAndHours {
                rate: 0.10_f64,
                semester_1: OutputHoursRow::new(
                    -1_f64, -1_f64, 12.00_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64,
                    -1_f64, -1_f64, -1_f64, -1_f64, 12.00_f64,
                ),
                semester_2: OutputHoursRow::new(
                    -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64,
                    -1_f64, 40.00_f64, -1_f64, 40.00_f64,
                ),
                year: OutputHoursRow::new(
                    -1_f64, -1_f64, 12.00_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64,
                    -1_f64, -1_f64, 40.00_f64, -1_f64, 52.00_f64,
                ),
            },
            total: OutputMainRateAndHours {
                rate: 15.75_f64,
                semester_1: OutputHoursRow::new(
                    942.00_f64,
                    232.00_f64,
                    1886.00_f64,
                    167.00_f64,
                    42.00_f64,
                    -1_f64,
                    216.00_f64,
                    70.03_f64,
                    -1_f64,
                    146.00_f64,
                    -1_f64,
                    644.00_f64,
                    -1_f64,
                    4345.03_f64,
                ),
                semester_2: OutputHoursRow::new(
                    976.00_f64,
                    122.00_f64,
                    2088.00_f64,
                    162.00_f64,
                    43.00_f64,
                    -1_f64,
                    239.00_f64,
                    106.00_f64,
                    128.00_f64,
                    147.00_f64,
                    -1_f64,
                    543.00_f64,
                    -1_f64,
                    4554.00_f64,
                ),
                year: OutputHoursRow::new(
                    1918.00_f64,
                    354.00_f64,
                    3974.00_f64,
                    329.00_f64,
                    85.00_f64,
                    -1_f64,
                    455.00_f64,
                    176.03_f64,
                    128.00_f64,
                    293.00_f64,
                    -1_f64,
                    1187.00_f64,
                    -1_f64,
                    8899.03_f64,
                ),
            },
        },
        personal_tables: vec![OutputPersonalTables {
            worker_last_name: "Хандецький".to_string(),
            tables: vec![
                OutputPersonalTable {
                    id: 1,
                    first_name: "Володимир".to_string(),
                    middle_name: "Сергійович".to_string(),
                    last_name: "Хандецький".to_string(),
                    comment_semester_1: "Гарант ОНП (PhD)".to_string(),
                    comment_semester_2: "Гарант ОНП (PhD)".to_string(),
                    rank: "завідувач кафедри, д.т.н. професор, професор".to_string(),
                    semester_1: vec![
                        OutputPersonalSemesterRow {
                            name: "Комп'ютерні мережі".to_string(),
                            learning_form: "Д".to_string(),
                            speciality: "КІ".to_string(),
                            group: "КІ-23у-1".to_string(),
                            course: "2".to_string(),
                            students_count: 21,
                            hours: OutputHoursRow::new(
                                32_f64, -1_f64, 32_f64, 5_f64, 2_f64, -1_f64, -1_f64, -1_f64,
                                -1_f64, 3_f64, -1_f64, -1_f64, -1_f64, 74_f64,
                            ),
                            merge_lectures_with_next: true,
                        },
                        OutputPersonalSemesterRow {
                            name: "Комп'ютерні мережі".to_string(),
                            learning_form: "Д".to_string(),
                            speciality: "КІ".to_string(),
                            group: "КІ-21-1,2".to_string(),
                            course: "4".to_string(),
                            students_count: 32,
                            hours: OutputHoursRow::new(
                                -1_f64, -1_f64, 32_f64, 8_f64, 2_f64, -1_f64, -1_f64, -1_f64,
                                -1_f64, 4_f64, -1_f64, -1_f64, -1_f64, 46_f64,
                            ),
                            merge_lectures_with_next: false,
                        },
                        OutputPersonalSemesterRow {
                            name: "Комп'ютерні мережі (захист КР)".to_string(),
                            learning_form: "Д".to_string(),
                            speciality: "КІ".to_string(),
                            group: "КІ-23у-1".to_string(),
                            course: "2".to_string(),
                            students_count: 21,
                            hours: OutputHoursRow::new(
                                -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64,
                                -1_f64, -1_f64, -1_f64, 40_f64, -1_f64, 40_f64,
                            ),
                            merge_lectures_with_next: false,
                        },
                        OutputPersonalSemesterRow {
                            name: "Комп'ютерні мережі (захист КР)".to_string(),
                            learning_form: "Д".to_string(),
                            speciality: "КІ".to_string(),
                            group: "КІ-21-1,2".to_string(),
                            course: "4".to_string(),
                            students_count: 32,
                            hours: OutputHoursRow::new(
                                -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64,
                                -1_f64, -1_f64, -1_f64, 128_f64, -1_f64, 128_f64,
                            ),
                            merge_lectures_with_next: false,
                        },
                        OutputPersonalSemesterRow {
                            name: "Випускні кваліфікаційні роботи (рецензування)".to_string(),
                            learning_form: "Д".to_string(),
                            speciality: "КС, КЕ".to_string(),
                            group: "".to_string(),
                            course: "2м".to_string(),
                            students_count: 2,
                            hours: OutputHoursRow::new(
                                -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64,
                                -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64,
                            ),
                            merge_lectures_with_next: false,
                        },
                        OutputPersonalSemesterRow {
                            name: "Технології глобальних мереж".to_string(),
                            learning_form: "Д".to_string(),
                            speciality: "КІ".to_string(),
                            group: "КІ-24м-1".to_string(),
                            course: "1м".to_string(),
                            students_count: 31,
                            hours: OutputHoursRow::new(
                                24_f64, -1_f64, 32_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64,
                                -1_f64, 4_f64, -1_f64, -1_f64, -1_f64, 60_f64,
                            ),
                            merge_lectures_with_next: false,
                        },
                        OutputPersonalSemesterRow {
                            name: "Випускні кваліфікаційні роботи (ЕК)".to_string(),
                            learning_form: "Д".to_string(),
                            speciality: "КІ".to_string(),
                            group: "КІ-23м-1".to_string(),
                            course: "2м".to_string(),
                            students_count: 18,
                            hours: OutputHoursRow::new(
                                -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, 9_f64, -1_f64,
                                -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, 9_f64,
                            ),
                            merge_lectures_with_next: false,
                        },
                        OutputPersonalSemesterRow {
                            name: "Кваліфікаційна робота (керівництво)".to_string(),
                            learning_form: "Д".to_string(),
                            speciality: "КІ".to_string(),
                            group: "КІ-23м-1".to_string(),
                            course: "2м".to_string(),
                            students_count: 2,
                            hours: OutputHoursRow::new(
                                -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, 21_f64, -1_f64,
                                -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, 21_f64,
                            ),
                            merge_lectures_with_next: false,
                        },
                        OutputPersonalSemesterRow {
                            name: "Практика виробнича: переддипломна".to_string(),
                            learning_form: "Д".to_string(),
                            speciality: "КІ".to_string(),
                            group: "КІ-23м-1".to_string(),
                            course: "2м".to_string(),
                            students_count: 2,
                            hours: OutputHoursRow::new(
                                -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, 6.7_f64,
                                -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, 6.7_f64,
                            ),
                            merge_lectures_with_next: false,
                        },
                        OutputPersonalSemesterRow {
                            name: "Комп'ютерна логіка (захист КП)".to_string(),
                            learning_form: "Д".to_string(),
                            speciality: "КІ".to_string(),
                            group: "КІ-23-1,2".to_string(),
                            course: "2".to_string(),
                            students_count: 2,
                            hours: OutputHoursRow::new(
                                -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64,
                                -1_f64, -1_f64, -1_f64, 8_f64, -1_f64, 8_f64,
                            ),
                            merge_lectures_with_next: false,
                        },
                    ],
                    semester_1_rate: 1.0_f64,
                    semester_1_total_day: OutputHoursRow::new(
                        56_f64, -1_f64, 96_f64, 13_f64, 4_f64, -1_f64, 30_f64, 6.7_f64, -1_f64,
                        11_f64, -1_f64, 176_f64, -1_f64, 392.7_f64,
                    ),
                    semester_1_total_evening: OutputHoursRow::new(
                        -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64,
                        -1_f64, -1_f64, -1_f64, -1_f64, -1_f64,
                    ),
                    semester_1_total: OutputHoursRow::new(
                        56_f64, -1_f64, 96_f64, 13_f64, 4_f64, -1_f64, 30_f64, 6.7_f64, -1_f64,
                        11_f64, -1_f64, 176_f64, -1_f64, 392.7_f64,
                    ),
                    semester_2: vec![
                        OutputPersonalSemesterRow {
                            name: "Випускні кваліфікаційні роботи (керівництво)".to_string(),
                            learning_form: "Д".to_string(),
                            speciality: "КІ".to_string(),
                            group: "КІ-21, КІ-23у".to_string(),
                            course: "4, 2".to_string(),
                            students_count: 6,
                            hours: OutputHoursRow::new(
                                -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, 18_f64, -1_f64,
                                -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, 18_f64,
                            ),
                            merge_lectures_with_next: false,
                        },
                        OutputPersonalSemesterRow {
                            name: "Переддипломна практика".to_string(),
                            learning_form: "Д".to_string(),
                            speciality: "КІ".to_string(),
                            group: "КІ-21, КІ-23у".to_string(),
                            course: "4, 2".to_string(),
                            students_count: 6,
                            hours: OutputHoursRow::new(
                                -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, 12_f64,
                                -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, 12_f64,
                            ),
                            merge_lectures_with_next: false,
                        },
                        OutputPersonalSemesterRow {
                            name: "Випускні кваліфікаційні роботи (рецензування)".to_string(),
                            learning_form: "Д".to_string(),
                            speciality: "КС".to_string(),
                            group: "КС-21".to_string(),
                            course: "4".to_string(),
                            students_count: 3,
                            hours: OutputHoursRow::new(
                                -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64,
                                -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64,
                            ),
                            merge_lectures_with_next: false,
                        },
                        OutputPersonalSemesterRow {
                            name: "Сучасні технології обміну інформацією в Інтернет".to_string(),
                            learning_form: "Д".to_string(),
                            speciality: "КІ".to_string(),
                            group: "ВД".to_string(),
                            course: "1".to_string(),
                            students_count: 24,
                            hours: OutputHoursRow::new(
                                36_f64, -1_f64, 36_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64,
                                -1_f64, 3_f64, -1_f64, -1_f64, -1_f64, 75_f64,
                            ),
                            merge_lectures_with_next: false,
                        },
                        OutputPersonalSemesterRow {
                            name: "Програмування (захист КР)".to_string(),
                            learning_form: "Д".to_string(),
                            speciality: "КІ".to_string(),
                            group: "КІ-24-1".to_string(),
                            course: "1".to_string(),
                            students_count: 10,
                            hours: OutputHoursRow::new(
                                -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64,
                                -1_f64, -1_f64, -1_f64, 30_f64, -1_f64, 30_f64,
                            ),
                            merge_lectures_with_next: false,
                        },
                        OutputPersonalSemesterRow {
                            name: "Випускні кваліфікаційні роботи (ЕК)".to_string(),
                            learning_form: "Д".to_string(),
                            speciality: "КІ".to_string(),
                            group: "КІ-21, КІ-23у".to_string(),
                            course: "".to_string(),
                            students_count: 0,
                            hours: OutputHoursRow::new(
                                -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, 27_f64, -1_f64,
                                -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, 27_f64,
                            ),
                            merge_lectures_with_next: false,
                        },
                        OutputPersonalSemesterRow {
                            name: "Комп'ютерні мережі".to_string(),
                            learning_form: "Д".to_string(),
                            speciality: "КІ".to_string(),
                            group: "КІ-23у-1".to_string(),
                            course: "2".to_string(),
                            students_count: 21,
                            hours: OutputHoursRow::new(
                                24_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64,
                                -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, 24_f64,
                            ),
                            merge_lectures_with_next: true,
                        },
                        OutputPersonalSemesterRow {
                            name: "Комп'ютерні мережі".to_string(),
                            learning_form: "Д".to_string(),
                            speciality: "КІ".to_string(),
                            group: "КІ-21-1,2".to_string(),
                            course: "4".to_string(),
                            students_count: 32,
                            hours: OutputHoursRow::new(
                                -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64,
                                -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64,
                            ),
                            merge_lectures_with_next: false,
                        },
                    ],
                    semester_2_rate: 1.0_f64,
                    semester_2_total_day: OutputHoursRow::new(
                        60_f64, -1_f64, 36_f64, -1_f64, -1_f64, -1_f64, 45_f64, 12_f64, -1_f64,
                        3_f64, -1_f64, 30_f64, -1_f64, 186_f64,
                    ),
                    semester_2_total_evening: OutputHoursRow::new(
                        -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64,
                        -1_f64, -1_f64, -1_f64, -1_f64, -1_f64,
                    ),
                    semester_2_total: OutputHoursRow::new(
                        60_f64, -1_f64, 36_f64, -1_f64, -1_f64, -1_f64, 45_f64, 12_f64, -1_f64,
                        3_f64, -1_f64, 30_f64, -1_f64, 186_f64,
                    ),
                    year_total: OutputHoursRow::new(
                        116_f64, -1_f64, 132_f64, 13_f64, 4_f64, -1_f64, 75_f64, 18.7_f64, -1_f64,
                        14_f64, -1_f64, 206_f64, -1_f64, 578.7_f64,
                    ),
                },
                OutputPersonalTable {
                    id: 16,
                    first_name: "Володимир".to_string(),
                    middle_name: "Сергійович".to_string(),
                    last_name: "Хандецький".to_string(),
                    comment_semester_1: "01.11.23-20.01.24".to_string(),
                    comment_semester_2: String::new(),
                    rank: "завідувач кафедри, д.т.н. професор, професор".to_string(),
                    semester_1: vec![
                        OutputPersonalSemesterRow {
                            name: "Комп'ютерні мережі".to_string(),
                            learning_form: "Д".to_string(),
                            speciality: "КС".to_string(),
                            group: "КС-22".to_string(),
                            course: "3".to_string(),
                            students_count: 53,
                            hours: OutputHoursRow::new(
                                16_f64, -1_f64, -1_f64, 13_f64, 2_f64, -1_f64, -1_f64, -1_f64,
                                -1_f64, 4_f64, -1_f64, -1_f64, -1_f64, 35_f64,
                            ),
                            merge_lectures_with_next: false,
                        },
                        OutputPersonalSemesterRow {
                            name: "Сучасні технології передачі інформації в комп'ютерних мережах"
                                .to_string(),
                            learning_form: "Д".to_string(),
                            speciality: "КІ".to_string(),
                            group: "PhD".to_string(),
                            course: "2А".to_string(),
                            students_count: 4,
                            hours: OutputHoursRow::new(
                                30_f64, -1_f64, 16_f64, 1_f64, 1_f64, -1_f64, -1_f64, -1_f64,
                                -1_f64, 1_f64, -1_f64, -1_f64, -1_f64, 49_f64,
                            ),
                            merge_lectures_with_next: false,
                        },
                        OutputPersonalSemesterRow {
                            name: "Комп'ютерні мережі (захист КР)".to_string(),
                            learning_form: "Д".to_string(),
                            speciality: "КІ".to_string(),
                            group: "КІ-23у-1".to_string(),
                            course: "2".to_string(),
                            students_count: 21,
                            hours: OutputHoursRow::new(
                                -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64,
                                -1_f64, -1_f64, -1_f64, 44_f64, -1_f64, 44_f64,
                            ),
                            merge_lectures_with_next: false,
                        },
                    ],
                    semester_1_rate: 0.5_f64,
                    semester_1_total_day: OutputHoursRow::new(
                        46_f64, -1_f64, 16_f64, 14_f64, 3_f64, -1_f64, -1_f64, -1_f64, -1_f64,
                        5_f64, -1_f64, 44_f64, -1_f64, 128_f64,
                    ),
                    semester_1_total_evening: OutputHoursRow::new(
                        -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64,
                        -1_f64, -1_f64, -1_f64, -1_f64, -1_f64,
                    ),
                    semester_1_total: OutputHoursRow::new(
                        46_f64, -1_f64, 16_f64, 14_f64, 3_f64, -1_f64, -1_f64, -1_f64, -1_f64,
                        5_f64, -1_f64, 44_f64, -1_f64, 128_f64,
                    ),
                    semester_2: vec![
                        OutputPersonalSemesterRow {
                            name: "Комп'ютерні мережі".to_string(),
                            learning_form: "Д".to_string(),
                            speciality: "КІ".to_string(),
                            group: "КІ-23у-1".to_string(),
                            course: "2".to_string(),
                            students_count: 21,
                            hours: OutputHoursRow::new(
                                -1_f64, -1_f64, 16_f64, 5_f64, 2_f64, -1_f64, -1_f64, -1_f64,
                                -1_f64, 3_f64, -1_f64, -1_f64, -1_f64, 26_f64,
                            ),
                            merge_lectures_with_next: false,
                        },
                        OutputPersonalSemesterRow {
                            name: "Комп'ютерні мережі".to_string(),
                            learning_form: "Д".to_string(),
                            speciality: "КІ".to_string(),
                            group: "КІ-21-1,2".to_string(),
                            course: "4".to_string(),
                            students_count: 32,
                            hours: OutputHoursRow::new(
                                -1_f64, -1_f64, 16_f64, 8_f64, 2_f64, -1_f64, -1_f64, -1_f64,
                                -1_f64, 3_f64, -1_f64, -1_f64, -1_f64, 30_f64,
                            ),
                            merge_lectures_with_next: false,
                        },
                        OutputPersonalSemesterRow {
                            name: "Технології глобальних мереж".to_string(),
                            learning_form: "Д".to_string(),
                            speciality: "КІ".to_string(),
                            group: "КІ-24м-1".to_string(),
                            course: "1м".to_string(),
                            students_count: 31,
                            hours: OutputHoursRow::new(
                                14_f64, -1_f64, 32_f64, 7_f64, 2_f64, -1_f64, -1_f64, -1_f64,
                                -1_f64, 4_f64, -1_f64, -1_f64, -1_f64, 59_f64,
                            ),
                            merge_lectures_with_next: false,
                        },
                        OutputPersonalSemesterRow {
                            name: "Викладацька практика".to_string(),
                            learning_form: "Д".to_string(),
                            speciality: "КІ".to_string(),
                            group: "PhD".to_string(),
                            course: "2А".to_string(),
                            students_count: 5,
                            hours: OutputHoursRow::new(
                                -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64,
                                30_f64, -1_f64, -1_f64, -1_f64, -1_f64, 30_f64,
                            ),
                            merge_lectures_with_next: false,
                        },
                    ],
                    semester_2_rate: 0.5_f64,
                    semester_2_total_day: OutputHoursRow::new(
                        14_f64, -1_f64, 64_f64, 20_f64, 6_f64, -1_f64, -1_f64, -1_f64, 30_f64,
                        11_f64, -1_f64, -1_f64, -1_f64, 145_f64,
                    ),
                    semester_2_total_evening: OutputHoursRow::new(
                        -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64, -1_f64,
                        -1_f64, -1_f64, -1_f64, -1_f64, -1_f64,
                    ),
                    semester_2_total: OutputHoursRow::new(
                        14_f64, -1_f64, 64_f64, 20_f64, 6_f64, -1_f64, -1_f64, -1_f64, 30_f64,
                        11_f64, -1_f64, -1_f64, -1_f64, 145_f64,
                    ),
                    year_total: OutputHoursRow::new(
                        60_f64, -1_f64, 80_f64, 34_f64, 9_f64, -1_f64, -1_f64, -1_f64, 30_f64,
                        16_f64, -1_f64, 44_f64, -1_f64, 273_f64,
                    ),
                },
            ],
        }],
    }
}
