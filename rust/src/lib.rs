pub mod api;
mod excel;
mod frb_generated;

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parsing() {
        let file_path = "input.xlsx";
        let parsed_data = api::excel_interface::parse_excel_file(file_path.to_string());
        eprintln!("Parsed file with {} lines.", parsed_data.data.len());
        for (key, value) in parsed_data.data {
            eprintln!("Sheet: {}, {} rows", key, value.len());
            eprintln!("First row: {:#?}", value[0]);
        }
    }

    #[test]
    fn test_generating() {
        let file_path = "output.xlsx";
        let exported_tables = excel::document_generator::get_test_output_data();
        api::excel_interface::write_excel_file(file_path.to_string(), exported_tables);
    }
}
