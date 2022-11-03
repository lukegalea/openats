defmodule Mix.Tasks.Openats.GenerateResources do
  use Mix.Task
  require Logger
  #alias JsonSchema.Parser.{ParserError, ParserWarning}

  @shortdoc "Regenerates the resources from the open hr schema"

  @moduledoc """
  This is where we would put any long form documentation and doctests.
  """

  @impl Mix.Task
  def run(_args) do
    #Cleaned via removing xml and samples
    #  (find . -type d -name samples -exec rm -rf {} \;) and so on
    # And -> "title": "([^"]+)",\n
    # To "title": "$1",\n    "$id": "https://www.hropenstandards.org/hros/$1.json",\n
    #
    schema_paths = ["docs/hropenstandards/cleaned"]

    files = resolve_all_paths(schema_paths)

    # IO.inspect(files)

    output_path = create_output_dir()
    generate(files, output_path)
  end

  # Liberated from json-schema-to-elm
  defp resolve_all_paths(paths) do
    paths
    |> Enum.filter(&File.exists?/1)
    |> Enum.reduce([], fn filename, files ->
      cond do
        File.dir?(filename) ->
          walk_directory(filename) ++ files

        String.ends_with?(filename, ".json") ->
          [filename | files]

        true ->
          files
      end
    end)
  end

  defp walk_directory(dir) do
    dir
    |> File.ls!()
    |> Enum.reduce([], fn file, files ->
      filename = "#{dir}/#{file}"

      cond do
        File.dir?(filename) ->
          walk_directory(filename) ++ files

        String.ends_with?(file, ".json") ->
          [filename | files]

        true ->
          files
      end
    end)
  end

  defp create_output_dir() do
    module_name = "HROS"
    output_dir = "docs/hropenstandards/generated"

    "#{output_dir}/src"
    |> Path.join(module_name)
    |> String.replace(".", "/")
    |> File.mkdir_p!()

    "#{output_dir}/tests"
    |> Path.join(module_name)
    |> String.replace(".", "/")
    |> File.mkdir_p!()

    module_name
  end

  def generate(schema_paths, module_name) do
    Logger.info("Parsing JSON schema files!")
    parser_result = JsonSchema.parse_schema_files(schema_paths)

    pretty_parser_warnings(parser_result.warnings)

    if length(parser_result.errors) > 0 do
      pretty_parser_errors(parser_result.errors)
    else
      Logger.info("Converting to code!")

      printer_result = Printer.print_schemas(parser_result.schema_dict, module_name)

      tests_printer_result = Printer.print_schemas_tests(parser_result.schema_dict, module_name)

      cond do
        length(printer_result.errors) > 0 ->
          pretty_printer_errors(printer_result.errors)

        length(tests_printer_result.errors) > 0 ->
          pretty_printer_errors(tests_printer_result.errors)

        true ->
          Logger.info("Printing code to file(s)!")

          file_dict = printer_result.file_dict

          Enum.each(file_dict, fn {file_path, file_content} ->
            normalized_file_path =
              String.replace(
                file_path,
                module_name,
                String.replace(module_name, ".", "/")
              )

            Logger.debug(fn -> "Writing file '#{normalized_file_path}'" end)
            {:ok, file} = File.open(normalized_file_path, [:write])
            IO.binwrite(file, file_content)
            File.close(file)
            Logger.info("Created file '#{normalized_file_path}'")
          end)

          tests_file_dict = tests_printer_result.file_dict

          Enum.each(tests_file_dict, fn {file_path, file_content} ->
            normalized_file_path =
              String.replace(
                file_path,
                module_name,
                String.replace(module_name, ".", "/")
              )

            Logger.debug("Writing file '#{normalized_file_path}'")
            {:ok, file} = File.open(normalized_file_path, [:write])
            IO.binwrite(file, file_content)
            File.close(file)
            Logger.info("Created file '#{normalized_file_path}'")
          end)

          IO.puts("DONE!")
      end
    end
  end

  defp pretty_parser_warnings(warnings) do
    warnings
    |> Enum.each(fn {file_path, warnings} ->
      if length(warnings) > 0 do
        warning_header()

        warnings
        |> Enum.group_by(fn warning -> warning.warning_type end)
        |> Enum.each(fn {warning_type, warnings} ->
          pretty_warning_type =
            warning_type
            |> to_string
            |> String.replace("_", " ")
            |> String.downcase()

          padding =
            String.duplicate(
              "-",
              max(
                0,
                74 - String.length(pretty_warning_type) -
                  String.length(file_path)
              )
            )

          warnings
          |> Enum.each(fn warning ->
            print_header("--- #{pretty_warning_type} #{padding} #{file_path}\n")
            IO.puts(warning.message)
          end)
        end)
      end
    end)

    :ok
  end

  defp pretty_parser_errors(errors) do
    errors
    |> Enum.each(fn {file_path, errors} ->
      if length(errors) > 0 do
        errors
        |> Enum.group_by(fn err -> err.error_type end)
        |> Enum.each(fn {error_type, errors} ->
          pretty_error_type =
            error_type
            |> to_string
            |> String.replace("_", " ")
            |> String.upcase()

          padding =
            String.duplicate(
              "-",
              max(
                0,
                74 - String.length(pretty_error_type) - String.length(file_path)
              )
            )

          errors
          |> Enum.each(fn error ->
            print_header("--- #{pretty_error_type} #{padding} #{file_path}\n")
            IO.puts(error.message)
          end)
        end)
      end
    end)

    :ok
  end

  defp pretty_printer_errors(errors) do
    errors
    |> Enum.each(fn {file_path, errors} ->
      if length(errors) > 0 do
        errors
        |> Enum.group_by(fn err -> err.error_type end)
        |> Enum.each(fn {error_type, errors} ->
          pretty_error_type =
            error_type
            |> to_string
            |> String.replace("_", " ")
            |> String.upcase()

          padding =
            String.duplicate(
              "-",
              max(
                0,
                74 - String.length(pretty_error_type) - String.length(file_path)
              )
            )

          errors
          |> Enum.each(fn error ->
            print_header("--- #{pretty_error_type} #{padding} #{file_path}\n")
            IO.puts(error.message)
          end)
        end)
      end
    end)

    :ok
  end

  # defp print_error(str) do
  #   IO.puts(IO.ANSI.format([:cyan, str]))
  # end

  defp print_header(str) do
    IO.puts(IO.ANSI.format([:cyan, str]))
  end

  defp warning_header do
    header = String.duplicate("^", 35) <> " WARNINGS " <> String.duplicate("^", 35)

    IO.puts(IO.ANSI.format([:yellow, header]))
  end
end
