import 'core-js';
import React, { useEffect, useState } from 'react';
import axios from 'axios';
import PayPalButtons from './PayPalButtons';
import Checkbox from '@material-ui/core/Checkbox';
import FormControlLabel from '@material-ui/core/FormControlLabel';
import RadioGroup from '@material-ui/core/RadioGroup';
import Radio from '@material-ui/core/Radio';
import Slider from '@material-ui/core/Slider';
import TextField from '@material-ui/core/TextField';
import ExpansionPanel from '@material-ui/core/ExpansionPanel';
import ExpansionPanelSummary from '@material-ui/core/ExpansionPanelSummary';
import ExpansionPanelDetails from '@material-ui/core/ExpansionPanelDetails';
import './Registration.scss'
import PriceDetails from "./PriceDetails";

const Registration = ({ clientAuthtoken }) => {
  const RD_PRICE = 35;
  const MIN_RD_HARDSHIP_PRICE = 20;
  const STUDENT_PRICE = 10;

  const [firstName, setFirstName] = useState('');
  const [lastName, setLastName] = useState('');
  const [email, setEmail] = useState('');
  const [membershipType, setMembershipType] = useState('');
  const [membershipPrice, setMembershipPrice] = useState();
  const [sponsorStudent, setSponsorStudent] = useState(false);
  const [slidingScale, setSlidingScale] = useState(false);
  const [slidingScalePrice, setSlidingScalePrice] = useState(RD_PRICE);
  const [errors, setErrors] = useState({});
  const [showPaymentButtons, setShowPaymentButtons] = useState(false);
  const [paymentCompleted, setPaymentCompleted] = useState(false);
  const [processingPayment, setProcessingPayment] = useState(false);

  const tokenElement = document.querySelector("meta[name='csrf-token']");
  const csrf = tokenElement && tokenElement.getAttribute("content");
  axios.defaults.headers.common['X-CSRF-TOKEN'] = csrf;
  axios.defaults.headers.common['Content-Type'] = 'application/json';
  axios.defaults.headers.common['X-Auth-Token'] = clientAuthtoken;

  useEffect(() => {
    if (!membershipType) return;
    if (membershipType === 'Student') return setMembershipPrice(STUDENT_PRICE);
    if (sponsorStudent) return setMembershipPrice(RD_PRICE + STUDENT_PRICE);
    setMembershipPrice(slidingScalePrice || RD_PRICE);
  }, [membershipType, sponsorStudent, slidingScalePrice]);

  const handleMembershipSelect = (event) => {
    setErrors({ ...errors, membershipType: false });
    setSlidingScalePrice(RD_PRICE);
    setSponsorStudent(false);
    setSlidingScale(false);
    setMembershipType(event.target.value)
  };

  const handleSlidingScalePriceChange = (_event, newValue) => {
    setSlidingScalePrice(newValue);
  };

  const handleSponsorStudentCheckbox = (_event, newValue) => {
    setSponsorStudent(newValue);
    setSlidingScalePrice(RD_PRICE);
  };

  const handleSlidingScaleCheckbox = (_event, newValue) => {
    setSlidingScale(newValue);
    setSlidingScalePrice(RD_PRICE);
  };

  const onFirstNameChange = (event) => {
    setShowPaymentButtons(false);
    setErrors({ ...errors, firstName: false });
    setFirstName(event.target.value);
  };

  const onLastNameChange = (event) => {
    setShowPaymentButtons(false);
    setErrors({ ...errors, lastName: false });
    setLastName(event.target.value);
  };

  const onEmailChange = (event) => {
    setShowPaymentButtons(false)
    setErrors({ ...errors, email: false });
    setEmail(event.target.value);
  };

  const invalidEmailAddress = () => {
    if (!email) return true;
    if (!(/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,9})+$/.test(email))) return true;
  };

  const submitForm = async () => {
    setShowPaymentButtons(false);

    const errorsObject = {
      ...(!firstName && { firstName: true }),
      ...(!lastName && { lastName: true }),
      ...(invalidEmailAddress() && { email: true }),
      ...(!membershipType && { membershipType: true })
    };

    setErrors(errorsObject);

    if(Object.values(errorsObject).find(item => item === true)) return;

    try {
      const response = await axios.get(`/api/members/search?email=${email}`);

      if (response.status === 200) {
        setErrors({...errors, base: 'Your membership is already active for the current year'});
        setPaymentCompleted(true);
      } else {
        setShowPaymentButtons(true);
      }
    } catch {
      setShowPaymentButtons(true);
    }
  };

  const saveMembership = async () => {
    const params = {
      first_name: firstName,
      last_name: lastName,
      email,
      membership_type: membershipType
    };

    return await axios.post('/api/members', params);
  };

  return (
    <>
      <PriceDetails/>

      <ExpansionPanel expanded={!showPaymentButtons && !paymentCompleted} disabled={showPaymentButtons || paymentCompleted}>
        <ExpansionPanelSummary>
          <div>Step 1: Contact Information</div>
        </ExpansionPanelSummary>
        <ExpansionPanelDetails>
          <div className='form'>
            <TextField
              label='First Name'
              variant='outlined'
              required
              error={errors.firstName}
              onChange={onFirstNameChange}
              disabled={showPaymentButtons}
              id='first_name'
            />
            <TextField
              label='Last Name'
              variant='outlined'
              required
              error={errors.lastName}
              onChange={onLastNameChange}
              disabled={showPaymentButtons}
              id='last_name'
            />
            <TextField
              label='Email'
              variant='outlined'
              required
              error={errors.email}
              onChange={onEmailChange}
              disabled={showPaymentButtons}
              id='email'
            />

            <div className='membership-type-container'>
              {errors.membershipType && <span className='membership-type-error'>*</span>}
              <RadioGroup
                className='membership-type-select'
                aria-label='membership-type'
                name='membership-type'
                onChange={handleMembershipSelect}
                disabled={showPaymentButtons}
                required
              >
                <FormControlLabel
                  value='RD'
                  control={<Radio color='default' disabled={showPaymentButtons} />}
                  label='RDN'
                  id='rd'
                />
                <FormControlLabel
                  value='Student'
                  control={<Radio color='default' disabled={showPaymentButtons} />}
                  label='Student/Intern'
                  id='student'
                />
              </RadioGroup>
            </div>

            {membershipType === 'RD' && <>
              {!slidingScale && <div>
                <label className='checkbox-container'>
                  <Checkbox
                    onChange={handleSponsorStudentCheckbox}
                    disabled={showPaymentButtons}
                    color='default'
                  />
                  <span className='checkbox-label' id='sponsor-a-student'>I would like to sponsor a Student's membership for just $10 more</span>
                </label>
              </div>}

              {!sponsorStudent && <>
                <div>
                  <label className='checkbox-container'>
                    <Checkbox onChange={handleSlidingScaleCheckbox} disabled={showPaymentButtons} color='default' />
                    <span className='checkbox-label' id='sliding-scale'>I would like to (anonymously) pay less than $35 due to financial hardship</span>
                  </label>
                </div>
                {slidingScale &&
                <div className='sliding-scale-price-slider'>
                  <label className='checkbox-label'>Choose an amount $20 - $35</label>
                  <Slider
                    defaultValue={RD_PRICE}
                    step={1}
                    min={MIN_RD_HARDSHIP_PRICE}
                    max={RD_PRICE}
                    onChange={handleSlidingScalePriceChange}
                    marks={[{value: 20, label: '$20'}, {value: 35, label: '$35'}]}
                    valueLabelDisplay='auto'
                    disabled={showPaymentButtons}
                  />
                </div>
                }
              </>}
            </>}

            {membershipPrice && <h5 className='header light'>Total: ${membershipPrice}</h5>}
            <div className='button-container'>
              <button
                className='btn'
                onClick={submitForm}
                disabled={processingPayment}
              >
                Pay Now
              </button>

            </div>
          </div>
        </ExpansionPanelDetails>
      </ExpansionPanel>

      <ExpansionPanel disabled={!showPaymentButtons || paymentCompleted} expanded={showPaymentButtons && !paymentCompleted}>
        <ExpansionPanelSummary>
          <div>Step 2: Payment Information</div>
        </ExpansionPanelSummary>
        <ExpansionPanelDetails>
          {showPaymentButtons && <div className='payment-panel-container'>
            <h5 className='header light'>Total: ${membershipPrice}</h5>
            <PayPalButtons
              membershipType={membershipType}
              price={membershipPrice}
              processingPayment={processingPayment}
              setProcessingPayment={setProcessingPayment}
              setPaymentCompleted={setPaymentCompleted}
              saveMembership={saveMembership}
            />
            <div>
              <button
                className='btn red'
                onClick={() => setShowPaymentButtons(false)}
                disabled={!showPaymentButtons || processingPayment}
              >
                Cancel
              </button>
            </div>
          </div>}
        </ExpansionPanelDetails>
      </ExpansionPanel>

      <ExpansionPanel disabled={!paymentCompleted} expanded={paymentCompleted}>
        <ExpansionPanelSummary>
          <div>Step 3: Membership Confirmation</div>
        </ExpansionPanelSummary>
        <ExpansionPanelDetails>
          <div className='confirmation-container'>
            <h3 className='header center orange-text'>HOORAY</h3>
            <h4 className='header center light'>{errors.base ? errors.base : 'Thank you for joining GADA!'}</h4>

            <h6 className='center header light teal-text'>The GADA membership year runs from June 1 to May 31.</h6>

            <h6 className='center header light'>You can confirm the status of your membership at any time
              <a href='/member_search' className='teal-text bold-text'> <b>here</b></a>.
            </h6>

            <h6 className='header center'>You can also check out our upcoming
              <b><a href='/events' className='green-text'> events</a></b>, read our
              <b><a href='/blogs' className='blue-text'> blog</a></b>, and get to know your
              <b><a href='/board_members' className='orange-text'> board members</a></b>.
            </h6>

            <h6 className='header center'>
              If you have any questions about GADA or your membership, don't hesitate to
              <b><a className='red-text' href='mailto:secretary@eatrightatlanta.org'> email us.</a></b>
            </h6>
          </div>
        </ExpansionPanelDetails>
      </ExpansionPanel>
    </>
  )
}

export default Registration;
