import React, { Dispatch, useCallback, useState } from "react";
import { Formik } from "formik";

import { Button, Heading, Paragraph, Input } from "components/base";
import { FORM_CONFIGS } from "utils/constants";
import {
  launchTransitAzure,
  skipTransitAzure,
} from "store/actions/configuration";
import { ConfigurationState } from "types/store";

interface ComponentProps {
  processedData: ConfigurationState["processedData"];
  pageDisabled: boolean;
  history: any;
  dispatch: Dispatch<any>;
}

const {
  launch_transit_azure: { initialValues, validations },
} = FORM_CONFIGS;

export default function StandardForm(props: ComponentProps) {
  const { dispatch, history, pageDisabled } = props;
  const [azureResponse, setAzureResponse] = useState<Boolean>();

  const handlePositiveResponse = useCallback(() => {
    setAzureResponse(true);
  }, []);

  const handleNegativeResponse = useCallback(() => {
    setAzureResponse(false);
    dispatch(skipTransitAzure({ command: true }, history));
  }, [dispatch, history]);

  const onSubmit = useCallback(
    (values) => {
      dispatch(launchTransitAzure(values, history));
    },
    [dispatch, history]
  );

  return (
    <Formik
      initialValues={initialValues}
      onSubmit={onSubmit}
      validationSchema={validations}
    >
      {({ values, handleChange, handleSubmit, errors }) => (
        <form className="launch-transit-azure-grid" onSubmit={handleSubmit}>
          <div className="text-block">
            <Heading
              customClasses="--dark"
              text="Launch Aviatrix Transit in Azure"
            ></Heading>
            <Paragraph
              customClasses="--light"
              text={
                azureResponse === undefined ? (
                  "Do you want to launch the Aviatrix transit in Azure?"
                ) : (
                  <span>
                    Enter your Azure API keys for the Azure deployment. Perform
                    the pre-requisites at{" "}
                    <a
                      target="blank"
                      href="https://docs.aviatrix.com/HowTos/Aviatrix_Account_Azure.html"
                    >
                      https://docs.aviatrix.com/HowTos/Aviatrix_Account_Azure.html
                    </a>
                  </span>
                )
              }
            />
          </div>
          {azureResponse === undefined && (
            <span className="btn-group">
              <Button
                variant="contained"
                customClasses="--blue"
                onClick={handlePositiveResponse}
                disabled={pageDisabled}
              >
                Yes
              </Button>
              <Button
                variant="outlined"
                customClasses="--blue"
                onClick={handleNegativeResponse}
                disabled={pageDisabled}
              >
                No
              </Button>
            </span>
          )}
          {azureResponse && (
            <div className="form-fields">
              <Input
                value={values.azure_subscription_id}
                name="azure_subscription_id"
                label="Subscription ID"
                variant="outlined"
                customClasses="--standard --blue --small"
                onChange={handleChange}
                error={Boolean(errors.azure_subscription_id)}
                helperText={errors.azure_subscription_id}
                disabled={pageDisabled}
              />
              <Input
                value={values.azure_directory_id}
                name="azure_directory_id"
                label="Directory (Tenant) ID"
                variant="outlined"
                customClasses="--standard --blue --small"
                onChange={handleChange}
                error={Boolean(errors.azure_directory_id)}
                helperText={errors.azure_directory_id}
                disabled={pageDisabled}
              />
              <Input
                value={values.azure_application_id}
                name="azure_application_id"
                label="Application (Client) ID"
                variant="outlined"
                customClasses="--standard --blue --small"
                onChange={handleChange}
                error={Boolean(errors.azure_application_id)}
                helperText={errors.azure_application_id}
                disabled={pageDisabled}
              />
              <Input
                value={values.azure_application_key}
                name="azure_application_key"
                label="Application Key (Client Secret)"
                variant="outlined"
                customClasses="--standard --blue --small"
                onChange={handleChange}
                error={Boolean(errors.azure_application_key)}
                helperText={errors.azure_application_key}
                disabled={pageDisabled}
                type="password"
              />
              <span className="btn-submit">
                <Button
                  type="submit"
                  variant="contained"
                  customClasses=" --blue"
                  disabled={pageDisabled}
                >
                  Continue
                </Button>
              </span>
            </div>
          )}
        </form>
      )}
    </Formik>
  );
}
