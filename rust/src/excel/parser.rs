use std::collections::HashMap;

use crate::excel::data::InputRawRow;
use umya_spreadsheet::{Worksheet, reader};

#[derive(Debug)]
pub struct InputHeaderCoordinates {
    pub learning_form_x: u32,           // Форма навчання
    pub speciality_x: u32,              // Спеціальність
    pub name_x: u32,                    // Назва дисципліни
    pub course_x: u32,                  // Курс
    pub semester_x: u32,                // Семестр
    pub weeks_count_x: u32,             // Кількість тижнів
    pub students_count_x: u32,          // Кількість студентів
    pub flows_count_x: u32,             // Кількість потоків
    pub groups_count_x: u32,            // Кількість груп
    pub subgroups_count_x: u32,         // Кількість підгруп
    pub lectures_planned_count_x: u32,  // Лекції по плану
    pub lectures_total_count_x: u32,    // Лекції всього
    pub practices_planned_count_x: u32, // Практичні (семінарські) по плану
    pub practices_total_count_x: u32,   // Практичні (семінарські) всього
    pub labs_planned_count_x: u32,      // Лабораторні по плану
    pub labs_total_count_x: u32,        // Лабораторні всьго
    pub exams_x: u32,                   // Екзамени
    pub exam_consults_x: u32,           // Консультації перед екзаменом
    pub tests_x: u32,                   // Заліки
    pub qual_works_x: u32,              // Кваліфікаційні роботи (проєкти)
    pub certification_exams_x: u32,     // Атестаційні екзамени
    pub working_practice_x: u32,        // Виробнича практика
    pub teaching_practice_x: u32,       // Навчальна практика
    pub consults_x: u32,                // Поточні консультації
    pub individual_works_x: u32,        // Індивідуальні завдання
    pub course_works_x: u32,            // Курсові роботи (проєкти)
    pub postgraduate_exams_x: u32,      // Проведення аспірантських екзаменів
    pub supervising_x: u32,             // Керівництво аспірантами та здобувачами,
    // консультування докторантів.
    pub internship_x: u32, // Стажування
}

impl Default for InputHeaderCoordinates {
    fn default() -> Self {
        // It is default BUT not recommended to use.
        Self {
            learning_form_x: 2,
            speciality_x: 3,
            name_x: 4,
            course_x: 5,
            semester_x: 6,
            weeks_count_x: 7,
            students_count_x: 8,
            flows_count_x: 9,
            groups_count_x: 10,
            subgroups_count_x: 11,
            lectures_planned_count_x: 12,
            lectures_total_count_x: 13,
            practices_planned_count_x: 14,
            practices_total_count_x: 15,
            labs_planned_count_x: 16,
            labs_total_count_x: 17,
            exams_x: 18,
            exam_consults_x: 19,
            tests_x: 20,
            qual_works_x: 21,
            certification_exams_x: 22,
            working_practice_x: 23,
            teaching_practice_x: 24,
            consults_x: 25,
            individual_works_x: 26,
            course_works_x: 27,
            postgraduate_exams_x: 28,
            supervising_x: 29,
            internship_x: 30,
        }
    }
}

impl InputHeaderCoordinates {
    pub fn new_empty() -> Self {
        Self {
            learning_form_x: 0,
            speciality_x: 0,
            name_x: 0,
            course_x: 0,
            semester_x: 0,
            weeks_count_x: 0,
            students_count_x: 0,
            flows_count_x: 0,
            groups_count_x: 0,
            subgroups_count_x: 0,
            lectures_planned_count_x: 0,
            lectures_total_count_x: 0,
            practices_planned_count_x: 0,
            practices_total_count_x: 0,
            labs_planned_count_x: 0,
            labs_total_count_x: 0,
            exams_x: 0,
            exam_consults_x: 0,
            tests_x: 0,
            qual_works_x: 0,
            certification_exams_x: 0,
            working_practice_x: 0,
            teaching_practice_x: 0,
            consults_x: 0,
            individual_works_x: 0,
            course_works_x: 0,
            postgraduate_exams_x: 0,
            supervising_x: 0,
            internship_x: 0,
        }
    }

    pub fn from_vector(values: &Vec<String>) -> Self {
        let mut s = Self::new_empty();

        let mut i: u32 = 0;
        let mut h: &mut u32;
        while i < (values.len() as u32) {
            let v = &values[i as usize].to_lowercase();
            if v.contains("форм") && v.contains("навч") {
                s.learning_form_x = i + 1;
                i += 1;
                s.speciality_x = i + 1;
                i += 1;
                s.name_x = i + 1;
                i += 1;
                continue;
            } else if v == "курс" {
                h = &mut s.course_x;
            } else if v == "семестр" {
                h = &mut s.semester_x;
            } else if v.contains("кільк") && v.contains("тижн") {
                h = &mut s.weeks_count_x;
            } else if v.contains("кільк") && v.contains("студ") {
                h = &mut s.students_count_x;
            } else if v.contains("кільк") && v.contains("поток") {
                h = &mut s.flows_count_x;
            } else if v.contains("кільк") && v.contains("підгр") {
                h = &mut s.subgroups_count_x;
            } else if v.contains("кільк") && v.contains("груп") {
                h = &mut s.groups_count_x;
            } else if v.contains("лекц") && v.contains("план") {
                h = &mut s.lectures_planned_count_x;
            } else if v.contains("лекц") && v.contains("всь") {
                h = &mut s.lectures_total_count_x;
            } else if v.contains("практ") && v.contains("план") {
                h = &mut s.practices_planned_count_x;
            } else if v.contains("практ") && v.contains("всь") {
                h = &mut s.practices_total_count_x;
            } else if v.contains("лаб") && v.contains("план") {
                h = &mut s.labs_planned_count_x;
            } else if v.contains("лаб") && v.contains("всь") {
                h = &mut s.labs_total_count_x;
            } else if v == "екзамени" {
                h = &mut s.exams_x;
            } else if v.contains("консульт") && v.contains("екз") {
                h = &mut s.exam_consults_x;
            } else if v.contains("залік") {
                h = &mut s.tests_x;
            } else if (v.contains("диплом") || v.contains("кваліф")) && v.contains("роб")
            {
                h = &mut s.qual_works_x;
            } else if (v.contains("атест") || v.contains("кваліф")) && v.contains("екзам")
            {
                h = &mut s.certification_exams_x;
            } else if v.contains("вироб") && v.contains("практ") {
                h = &mut s.working_practice_x;
            } else if v.contains("навч") && v.contains("практ") {
                h = &mut s.teaching_practice_x;
            } else if v.contains("поточн") && v.contains("конс") {
                h = &mut s.consults_x;
            } else if v.contains("інд") && v.contains("завд") {
                h = &mut s.individual_works_x;
            } else if v.contains("курс") && (v.contains("роб") || v.contains("про")) {
                h = &mut s.course_works_x;
            } else if v.contains("аспір") && v.contains("екз") {
                h = &mut s.postgraduate_exams_x;
            } else if v.contains("керівн") && v.contains("аспір") {
                h = &mut s.supervising_x;
            } else if v == "стажування" {
                h = &mut s.internship_x;
            } else {
                i += 1;
                continue;
            }
            *h = i + 1;
            i += 1;
        }

        return s;
    }
}

pub fn read_row_from_worksheet(
    sheet: &Worksheet,
    header: &InputHeaderCoordinates,
    y: u32,
) -> InputRawRow {
    let learning_form = if header.learning_form_x > 0 {
        sheet.get_value((header.learning_form_x, y))
    } else {
        String::new()
    };
    let speciality = if header.speciality_x > 0 {
        sheet.get_value((header.speciality_x, y))
    } else {
        String::new()
    };
    let name = if header.name_x > 0 {
        sheet.get_value((header.name_x, y))
    } else {
        String::new()
    };
    let course = if header.course_x > 0 {
        sheet.get_value((header.course_x, y))
    } else {
        String::new()
    };
    let semester = if header.semester_x > 0 {
        sheet.get_value((header.semester_x, y))
    } else {
        String::new()
    };
    let weeks_count = if header.weeks_count_x > 0 {
        sheet.get_value((header.weeks_count_x, y))
    } else {
        String::new()
    };
    let students_count = if header.students_count_x > 0 {
        sheet.get_value((header.students_count_x, y))
    } else {
        String::new()
    };
    let flows_count = if header.flows_count_x > 0 {
        sheet.get_value((header.flows_count_x, y))
    } else {
        String::new()
    };
    let groups_count = if header.groups_count_x > 0 {
        sheet.get_value((header.groups_count_x, y))
    } else {
        String::new()
    };
    let subgroups_count = if header.subgroups_count_x > 0 {
        sheet.get_value((header.subgroups_count_x, y))
    } else {
        String::new()
    };
    let lectures_planned_count = if header.lectures_planned_count_x > 0 {
        sheet.get_value((header.lectures_planned_count_x, y))
    } else {
        String::new()
    };
    let lectures_total_count = if header.lectures_total_count_x > 0 {
        sheet.get_value((header.lectures_total_count_x, y))
    } else {
        String::new()
    };
    let practices_planned_count = if header.practices_planned_count_x > 0 {
        sheet.get_value((header.practices_planned_count_x, y))
    } else {
        String::new()
    };
    let practices_total_count = if header.practices_total_count_x > 0 {
        sheet.get_value((header.practices_total_count_x, y))
    } else {
        String::new()
    };
    let labs_planned_count = if header.labs_planned_count_x > 0 {
        sheet.get_value((header.labs_planned_count_x, y))
    } else {
        String::new()
    };
    let labs_total_count = if header.labs_total_count_x > 0 {
        sheet.get_value((header.labs_total_count_x, y))
    } else {
        String::new()
    };
    let exams = if header.exams_x > 0 {
        sheet.get_value((header.exams_x, y))
    } else {
        String::new()
    };
    let exam_consults = if header.exam_consults_x > 0 {
        sheet.get_value((header.exam_consults_x, y))
    } else {
        String::new()
    };
    let tests = if header.tests_x > 0 {
        sheet.get_value((header.tests_x, y))
    } else {
        String::new()
    };
    let qual_works = if header.qual_works_x > 0 {
        sheet.get_value((header.qual_works_x, y))
    } else {
        String::new()
    };
    let certification_exams = if header.certification_exams_x > 0 {
        sheet.get_value((header.certification_exams_x, y))
    } else {
        String::new()
    };
    let working_practice = if header.working_practice_x > 0 {
        sheet.get_value((header.working_practice_x, y))
    } else {
        String::new()
    };
    let teaching_practice = if header.teaching_practice_x > 0 {
        sheet.get_value((header.teaching_practice_x, y))
    } else {
        String::new()
    };
    let consults = if header.consults_x > 0 {
        sheet.get_value((header.consults_x, y))
    } else {
        String::new()
    };
    let individual_works = if header.individual_works_x > 0 {
        sheet.get_value((header.individual_works_x, y))
    } else {
        String::new()
    };
    let course_works = if header.course_works_x > 0 {
        sheet.get_value((header.course_works_x, y))
    } else {
        String::new()
    };
    let postgraduate_exams = if header.postgraduate_exams_x > 0 {
        sheet.get_value((header.postgraduate_exams_x, y))
    } else {
        String::new()
    };
    let supervising = if header.supervising_x > 0 {
        sheet.get_value((header.supervising_x, y))
    } else {
        String::new()
    };
    let internship = if header.internship_x > 0 {
        sheet.get_value((header.internship_x, y))
    } else {
        String::new()
    };

    InputRawRow {
        learning_form,
        speciality,
        name,
        course,
        semester,
        weeks_count,
        students_count,
        flows_count,
        groups_count,
        subgroups_count,
        lectures_planned_count,
        lectures_total_count,
        practices_planned_count,
        practices_total_count,
        labs_planned_count,
        labs_total_count,
        exams,
        exam_consults,
        tests,
        qual_works,
        certification_exams,
        working_practice,
        teaching_practice,
        consults,
        individual_works,
        course_works,
        postgraduate_exams,
        supervising,
        internship,
    }
}

pub fn parse_file(file_path: &str) -> HashMap<String, Vec<InputRawRow>> {
    let path = std::path::Path::new(file_path);
    let book = reader::xlsx::read(path).unwrap();
    let sheets = book.get_sheet_collection();
    let mut map = HashMap::<String, Vec<InputRawRow>>::new();
    for i in 0..sheets.len() {
        let sheet = &sheets[i];
        println!("Spreadsheet #{}: {}", i, sheet.get_name());
        let values = parse_sheet(sheet);
        map.insert(sheet.get_name().to_string(), values);
    }
    return map;
}

fn find_table_start(sheet: &Worksheet) -> Option<(u32, u32)> {
    for i in 1..20 {
        let value = sheet.get_value((1, i));
        if value == "1" {
            return Some((1, i));
        }
    }
    return None;
}

fn read_header(sheet: &Worksheet, y: u32) -> Vec<String> {
    let mut values: Vec<String> = vec![];
    for x in 1..40 {
        values.push(sheet.get_value((x, y)));
    }
    return values;
}

fn parse_sheet(sheet: &Worksheet) -> Vec<InputRawRow> {
    let Some(table_start) = find_table_start(sheet) else {
        println!("Couldn't find starting point of the table :(");
        return vec![];
    };
    let header_raw = read_header(sheet, table_start.1 - 1);
    let header = InputHeaderCoordinates::from_vector(&header_raw);
    let mut raw_rows: Vec<InputRawRow> = vec![];
    let mut y = table_start.1 + 1;
    loop {
        let name_cell = sheet.get_value((header.name_x, y));
        let name_cell_trimmed = name_cell.trim();
        if name_cell_trimmed.is_empty() {
            break;
        }
        if name_cell_trimmed == "4" || sheet.get_value((header.speciality_x, y)).is_empty() {
            y += 1;
            continue;
        }
        let row = read_row_from_worksheet(sheet, &header, y);
        raw_rows.push(row);
        y += 1;
    }
    println!("Last row: {:#?}", raw_rows.last().unwrap());
    println!("Vec size: {}", raw_rows.len());
    return raw_rows;
}
