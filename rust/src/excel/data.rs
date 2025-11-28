use std::collections::HashMap;

#[derive(Debug)]
pub struct InputRawRow {
    pub learning_form: String,           // Форма навчання
    pub speciality: String,              // Спеціальність
    pub name: String,                    // Назва дисципліни
    pub course: String,                  // Курс
    pub semester: String,                // Семестр
    pub weeks_count: String,             // Кількість тижнів
    pub students_count: String,          // Кількість студентів
    pub flows_count: String,             // Кількість потоків
    pub groups_count: String,            // Кількість груп
    pub subgroups_count: String,         // Кількість підгруп
    pub lectures_planned_count: String,  // Лекції по плану
    pub lectures_total_count: String,    // Лекції всього
    pub practices_planned_count: String, // Практичні (семінарські) по плану
    pub practices_total_count: String,   // Практичні (семінарські) всього
    pub labs_planned_count: String,      // Лабораторні по плану
    pub labs_total_count: String,        // Лабораторні всьго
    pub exams: String,                   // Екзамени
    pub exam_consults: String,           // Консультації перед екзаменом
    pub tests: String,                   // Заліки
    pub qual_works: String,              // Кваліфікаційні роботи (проєкти)
    pub certification_exams: String,     // Атестаційні екзамени
    pub working_practice: String,        // Виробнича практика
    pub teaching_practice: String,       // Навчальна практика
    pub consults: String,                // Поточні консультації
    pub individual_works: String,        // Індивідуальні завдання
    pub individual_work_types: String,   // Види індивідуальних завдань
    pub course_works: String,            // Курсові роботи (проєкти)
    pub postgraduate_exams: String,      // Проведення аспірантських екзаменів
    pub supervising: String, // Керівництво аспірантами та здобувачами, консультування докторантів
    pub internship: String,  // Стажування
}

pub struct ParsedExcelFile {
    pub data: HashMap<String, Vec<InputRawRow>>,
}

pub struct ExportedData {
    pub year: u32,
    pub type_name: String,
    pub main_table: OutputMainTable,
    pub personal_tables: Vec<OutputPersonalTables>,
}

pub struct OutputMainTable {
    pub heads: Vec<OutputMainWorkerRow>,
    pub heads_total: OutputMainRateAndHours,
    pub professors: Vec<OutputMainWorkerRow>,
    pub professors_total: OutputMainRateAndHours,
    pub associate_professors: Vec<OutputMainWorkerRow>,
    pub associate_professors_total: OutputMainRateAndHours,
    pub lecturers: Vec<OutputMainWorkerRow>,
    pub lecturers_total: OutputMainRateAndHours,
    pub assistants: Vec<OutputMainWorkerRow>,
    pub assistants_total: OutputMainRateAndHours,
    pub part_timers: Vec<OutputMainWorkerRow>,
    pub part_timers_total: OutputMainRateAndHours,
    pub total: OutputMainRateAndHours,
}

pub struct OutputPersonalTables {
    pub worker_last_name: String,
    pub tables: Vec<OutputPersonalTable>,
}

pub struct OutputPersonalTable {
    pub id: u32,
    pub first_name: String,
    pub middle_name: String,
    pub last_name: String,
    pub comment_semester_1: String,
    pub comment_semester_2: String,
    pub rank: String,
    pub semester_1: Vec<OutputPersonalSemesterRow>,
    pub semester_1_rate: f64,
    pub semester_1_total_day: OutputHoursRow,
    pub semester_1_total_evening: OutputHoursRow,
    pub semester_1_total: OutputHoursRow,
    pub semester_2: Vec<OutputPersonalSemesterRow>,
    pub semester_2_rate: f64,
    pub semester_2_total_day: OutputHoursRow,
    pub semester_2_total_evening: OutputHoursRow,
    pub semester_2_total: OutputHoursRow,
    pub year_total: OutputHoursRow,
}

pub struct OutputPersonalSemesterRow {
    pub name: String,
    pub learning_form: String,
    pub speciality: String,
    pub group: String,
    pub course: String,
    pub students_count: u32,
    pub hours: OutputHoursRow,
    pub merge_lectures_with_next: bool,
}

pub struct OutputMainWorkerRow {
    pub first_name: String,
    pub middle_name: String,
    pub last_name: String,
    pub rank: String,
    pub rate_and_hours: OutputMainRateAndHours,
}

pub struct OutputMainRateAndHours {
    pub rate: f64,
    pub semester_1: OutputHoursRow,
    pub semester_2: OutputHoursRow,
    pub year: OutputHoursRow,
}

pub struct OutputHoursRow {
    pub lectures: f64,
    pub practices: f64,
    pub labs: f64,
    pub exams: f64,
    pub exam_consults: f64,
    pub tests: f64,
    pub qual_works: f64,
    pub working_practice: f64,
    pub teaching_practice: f64,
    pub consults: f64,
    pub individual_works: f64,
    pub course_works: f64,
    pub supervising: f64,
    pub total: f64,
}

impl OutputHoursRow {
    pub fn new(
        lectures: f64,
        practices: f64,
        labs: f64,
        exams: f64,
        exam_consults: f64,
        tests: f64,
        qual_works: f64,
        working_practice: f64,
        teaching_practice: f64,
        consults: f64,
        individual_works: f64,
        course_works: f64,
        supervising: f64,
        total: f64,
    ) -> Self {
        Self {
            lectures,
            practices,
            labs,
            exams,
            exam_consults,
            tests,
            qual_works,
            working_practice,
            teaching_practice,
            consults,
            individual_works,
            course_works,
            supervising,
            total,
        }
    }
}
