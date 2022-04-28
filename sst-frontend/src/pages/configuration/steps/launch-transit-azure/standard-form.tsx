import React, { Dispatch, useCallback, useState, useEffect } from "react";
import { Formik } from "formik";
import AzureLogo from "/Users/sjia/Aviatrix/sandbox-starter/sst-frontend/src/images/azure.png";
import AWSLogo from "/Users/sjia/Aviatrix/sandbox-starter/sst-frontend/src/images/aws.png";
import GCPLogo from "/Users/sjia/Aviatrix/sandbox-starter/sst-frontend/src/images/Google.png";
import { Button, Heading, Paragraph, Input } from "components/base";
import { FORM_CONFIGS } from "utils/constants";
import {
  launchTransitAzure,
  skipTransitAzure,
} from "store/actions/configuration";
import { ConfigurationState } from "types/store";
import axios from "axios";
import { FormControlLabel, Radio, RadioGroup } from "@material-ui/core";

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
  const [transitResponse, setTransitResponse] = useState<Boolean>();

  const handlePositiveResponse = useCallback(() => {
    setTransitResponse(true);
  }, []);

  const handleNegativeResponse = useCallback(() => {
    setTransitResponse(false);
    dispatch(skipTransitAzure({ command: true }, history));
  }, [dispatch, history]);

  const onSubmit = useCallback(
    (values) => {
      dispatch(launchTransitAzure(values, history));
    },
    [dispatch, history]
  );
  const [DataGCP,setDataGCP]=useState({
    CloudAGCP:false,
})
  const [DataAWS,setDataAWS]=useState({
    CloudAAWS:false,
  })
  const [DataAzure,setDataAzure]=useState({
    CloudAAzure:false,
  })
  useEffect(()=>{
    axios.get( "http://localhost:3003/get-statestatus")
        .then(res=>{     
          let cloudAData=res.data.data["stateName"];
          if (cloudAData === "gcpConfiguration"){
            setDataGCP({CloudAGCP:true})
            console.log('CloudA ',res.data.data["stateName"])}
          if (cloudAData === "awsConfiguration"){
            setDataAWS({CloudAAWS:true})
            console.log('CloudA ',res.data.data["stateName"])}
          if (cloudAData === "azureConfiguration"){
            setDataAzure({CloudAAzure:true})
            console.log('CloudA ',res.data.data["stateName"])}
          })
        .catch(err=>{
            console.log(err);
        })
},[])
  return (
    <Formik
      initialValues={initialValues}
      onSubmit={onSubmit}
      validationSchema={validations}
    >
      {({ values, handleChange, handleSubmit, errors }) => (
        <form className="launch-transit-azure-grid" onSubmit={handleSubmit}>
          {transitResponse === undefined && (
            <><div className="text-block">
              <Heading
                customClasses="--dark"
                text="Do you want to launch Aviatrix transit in another cloud?"
              ></Heading>
            </div><span className="btn-group">
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
              </span></>
          )}
          {transitResponse && DataGCP.CloudAGCP && (
                       <><div className="text-block">
              <Heading
                customClasses="--dark"
                text="Your Aviatrix infrastructure is in GCP. \n 
                Choose a cloud to launch Aviatrix Transit"
              ></Heading>
            </div><RadioGroup
              row
              name="cloudB"
              value={values.cloudB}
              onChange={handleChange}
            >
                <FormControlLabel
                  name="cloudB"
                  value="aws"
                  control={<Radio />}
                  label={<img
                    src={AWSLogo}
                    className="img-fluid"
                    width="120"
                    height="80" />} />
                <FormControlLabel
                  name="cloudB"
                  value="azure"
                  control={<Radio />}
                  label={<img
                    src={AzureLogo}
                    className="img-fluid"
                    width="140"
                    height="85" />} />
              </RadioGroup></>
                    )}
                    {transitResponse && DataAWS.CloudAAWS && (
                      <><div className="text-block">
              <Heading
                customClasses="--dark"
                text="Your Aviatrix infrastructure is in AWS. \n
                Choose a cloud to launch Aviatrix Transit"
              ></Heading>
            </div><RadioGroup
              row
              name="cloudB"
              value={values.cloudB}
              onChange={handleChange}
            >
                <FormControlLabel
                  name="cloudB"
                  value="gcp"
                  control={<Radio />}
                  label={<img
                    src={GCPLogo}
                    className="img-fluid"
                    width="120"
                    height="80" />} />
                <FormControlLabel
                  name="cloudB"
                  value="azure"
                  control={<Radio />}
                  label={<img
                    src={AzureLogo}
                    className="img-fluid"
                    width="140"
                    height="85" />} />
              </RadioGroup></>

          )}
           {transitResponse && DataAzure.CloudAAzure && (
             <><div className="text-block">
              <Heading
                customClasses="--dark"
                text="Your Aviatrix infrastructure is in Azure. \n 
                Choose a cloud to launch Aviatrix Transit"
              ></Heading>
            </div><RadioGroup
              row
              name="cloudB"
              value={values.cloudB}
              onChange={handleChange}
            >
                <FormControlLabel
                  name="cloudB"
                  value="gcp"
                  control={<Radio />}
                  label={<img
                    src={GCPLogo}
                    className="img-fluid"
                    width="120"
                    height="80" />} />
                <FormControlLabel
                  name="cloudB"
                  value="aws"
                  control={<Radio />}
                  label={<img
                    src={AWSLogo}
                    className="img-fluid"
                    width="140"
                    height="85" />} />
              </RadioGroup></>

          )}
                    {values.cloudB === "aws" && (
                       <><Input
                            error={Boolean(errors.access_key)}
                            value={values.access_key}
                            name="access_key_id"
                            label="Access Key ID"
                            variant="outlined"
                            customClasses="--standard --blue"
                            onChange={handleChange}
                            helperText={errors.access_key}
                            disabled={pageDisabled} /><Input
                              value={values.secret_access_key}
                              name="secret_access_key"
                              label="Secret Access Key"
                              variant="outlined"
                              customClasses="--standard --blue"
                              onChange={handleChange}
                              error={Boolean(errors.secret_access_key)}
                              helperText={errors.secret_access_key}
                              disabled={pageDisabled}
                              type="password" /></>
                    )}
                    {values.cloudB=== "azure" && (
                          <>
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
                            type="password"
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
                        </>
                    )}
                    {values.cloudB === "gcp" && (
                        <Input
                        name="gcp_credentials"
                        label="GCP Credentials"
                        id="gcp_credentials"
                      placeholder="Please copy and paste your GCP Credentials"
                      multiline
                      minRows={10}
                      maxRows={20}
                      value={values.gcp_credentials}
                      variant="outlined"
                      onChange={handleChange}
                      InputLabelProps={{style: {fontSize: 15}}}
                      inputProps={{style: {fontSize: 15}}} 
                      disabled={pageDisabled}
                      error={Boolean(errors.gcp_credentials)}
                      helperText={errors.gcp_credentials}
          />
                    )
                    } 
          </form>
      )}
          </Formik>
          );}
