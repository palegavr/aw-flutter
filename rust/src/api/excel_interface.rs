use crate::excel::{data, document_generator, parser};

pub fn parse_excel_file(file_path: String) -> data::ParsedExcelFile {
    let map = parser::parse_file(&file_path);
    return data::ParsedExcelFile { data: map };
}

pub fn write_excel_file(file_path: String, exported_tables: data::ExportedData) {
    document_generator::generate_output_file(&file_path, exported_tables);
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}
