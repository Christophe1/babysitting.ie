class GroupedChosenInput < SimpleForm::Inputs::GroupedCollectionSelectInput
  def input_html_classes
    super.push('chosen')
  end
end