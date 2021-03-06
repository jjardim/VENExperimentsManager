#import "VENExperimentTableViewCell.h"

@implementation VENExperimentTableViewCell

- (void)configureWithExperiment:(VENExperiment *)experiment {
    self.experiment = experiment;
    
    self.nameLabel.text     = experiment.name;
    self.detailsLabel.text  = experiment.details;
    
    [self.enabledSwitch setOn:experiment.enabled animated:NO];
    [self.enabledSwitch setEnabled:experiment.userEditable];
    
    if (!experiment) {
        [self.enabledSwitch setOn:NO];
        [self.enabledSwitch setEnabled:NO];
    }
    
    self.detailsLabel.numberOfLines = 3;
    [self.detailsLabel sizeToFit];
    
    if ([experiment supportsOptions]) {
        self.optionsLabel.alpha = 1;
        self.optionsField.alpha = 1;
        [self.optionsField setText:[self.experiment selectedOptionDescription]];
        [self.optionsField setDelegate:self];
        [[self.optionsField valueForKey:@"textInputTraits"] setValue:[UIColor clearColor] forKey:@"insertionPointColor"];
    }
    else {
        self.optionsLabel.alpha = 0;
        self.optionsField.alpha = 0;
    }
}


- (IBAction)switchValueChanged:(id)sender {
    BOOL isON = [((UISwitch *)sender) isOn];
    [VENExperimentsManager setExperimentWithIdentifier:self.experiment.identifier isEnabled:isON];
    NSDictionary *userInfo = @{VENExperimentEnabledNotificationUserInfoKey: @(isON)};
    [[NSNotificationCenter defaultCenter] postNotificationName:[VENExperimentsManager enabledChangedNotificationNameForIdentifier:self.experiment.identifier]
                                                        object:nil
                                                      userInfo:userInfo];
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [[self.experiment options] count];
}


- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component {
    return [[self.experiment options] objectForKey:[[[self.experiment options] allKeys] objectAtIndex:row]];
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSString *selectedOption = [[[self.experiment options] allKeys] objectAtIndex:row];
    [VENExperimentsManager setSelectedOptionForExperimentWithIdentifier:self.experiment.identifier
                                                         selectedOption:selectedOption];
    [self.optionsField setText:[self.experiment selectedOptionDescription]];
    NSDictionary *userInfo = @{VENExperimentOptionNotificationUserInfoKey: selectedOption};
    [[NSNotificationCenter defaultCenter] postNotificationName:[VENExperimentsManager optionChangedNotificationNameForIdentifier:self.experiment.identifier]
                                                        object:nil
                                                      userInfo:userInfo];

    [self.optionsField resignFirstResponder];
}


-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    UIPickerView *pickerView = [[UIPickerView alloc] init];
    pickerView.dataSource = self;
    pickerView.delegate = self;
    
    NSUInteger selectedIndex = [[[self.experiment options] allKeys] indexOfObject:self.experiment.selectedOption];
    [pickerView selectRow:selectedIndex inComponent:0 animated:YES];
    textField.inputView = pickerView;
    return YES;
}

@end
