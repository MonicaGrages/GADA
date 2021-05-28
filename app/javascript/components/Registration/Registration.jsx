import 'core-js';
import PropTypes from 'prop-types';
import React, { useEffect, useState } from 'react';
import axios from 'axios';
import PayPalButtons from './PayPalButtons';
import Checkbox from '@material-ui/core/Checkbox';
import FormControlLabel from '@material-ui/core/FormControlLabel';
import RadioGroup from '@material-ui/core/RadioGroup';
import Radio from '@material-ui/core/Radio';
import Slider from '@material-ui/core/Slider';
import TextField from '@material-ui/core/TextField';
import Accordion from '@material-ui/core/Accordion';
import AccordionSummary from '@material-ui/core/AccordionSummary';
import AccordionDetails from '@material-ui/core/AccordionDetails';
import './Registration.scss'

const Registration = ({
  clientAuthtoken,
  rdMembershipPrice,
  studentMembershipPrice,
  offerSlidingScaleMembershipPricing,
  minimumSlidingScaleRdMembershipPrice,
  rdMembershipDiscount,
  studentMembershipDiscount,
}) => {
  const determineDiscountedRdMembershipPrice = () => {
    if(!rdMembershipDiscount.discount_amount_in_dollars) return;

    return rdMembershipPrice - rdMembershipDiscount.discount_amount_in_dollars;
  }

  const determineDiscountedStudentMembershipPrice = () => {
    if(!studentMembershipDiscount.discount_amount_in_dollars) return;

    return studentMembershipPrice - studentMembershipDiscount.discount_amount_in_dollars;
  };

  const discountedRdMembershipPrice = determineDiscountedRdMembershipPrice();
  const totalRdMembershipPrice = discountedRdMembershipPrice || rdMembershipPrice;

  const discountedStudentMembershipPrice = determineDiscountedStudentMembershipPrice();
  const totalStudentMembershipPrice = discountedStudentMembershipPrice || studentMembershipPrice;

  const [firstName, setFirstName] = useState('');
  const [lastName, setLastName] = useState('');
  const [email, setEmail] = useState('');
  const [membershipType, setMembershipType] = useState('');
  const [membershipPrice, setMembershipPrice] = useState();
  const [sponsorStudent, setSponsorStudent] = useState(false);
  const [showSlidingScale, setShowSlidingScale] = useState(false);
  const [slidingScalePrice, setSlidingScalePrice] = useState(totalRdMembershipPrice);
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
    if (membershipType === 'Student') return setMembershipPrice(totalStudentMembershipPrice);
    if (sponsorStudent) return setMembershipPrice(totalRdMembershipPrice + totalStudentMembershipPrice);
    setMembershipPrice(slidingScalePrice || totalRdMembershipPrice);
  }, [membershipType, sponsorStudent, slidingScalePrice]);

  const handleMembershipSelect = (event) => {
    setErrors({ ...errors, membershipType: false });
    setSlidingScalePrice(totalRdMembershipPrice);
    setSponsorStudent(false);
    setShowSlidingScale(false);
    setMembershipType(event.target.value)
  };

  const handleSlidingScalePriceChange = (_event, newValue) => {
    setSlidingScalePrice(newValue);
  };

  const handleSponsorStudentCheckbox = (_event, newValue) => {
    setSponsorStudent(newValue);
    setSlidingScalePrice(totalRdMembershipPrice);
  };

  const handleSlidingScaleCheckbox = (_event, newValue) => {
    setShowSlidingScale(newValue);
    setSlidingScalePrice(totalRdMembershipPrice);
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
      <h5 className='header light'>
        <p>
          <span>GADA membership for RDNs costs </span>
          {discountedRdMembershipPrice && <span><s>{`$${rdMembershipPrice}`}</s> ${discountedRdMembershipPrice} (discounted until {rdMembershipDiscount.discount_end_date})</span>}
          {!discountedRdMembershipPrice && <span>${rdMembershipPrice}</span>}
        </p>
        <p>
          <span>and membership for students and interns costs </span>
          {discountedStudentMembershipPrice && <span><s>{`$${studentMembershipPrice}`}</s> ${discountedStudentMembershipPrice} (discounted until {studentMembershipDiscount.discount_end_date})</span>}
          {!discountedStudentMembershipPrice && <span>${studentMembershipPrice}</span>}
        </p>
      </h5>
      <Accordion expanded={!showPaymentButtons && !paymentCompleted} disabled={showPaymentButtons || paymentCompleted}>
        <AccordionSummary>
          <div>Step 1: Contact Information</div>
        </AccordionSummary>
        <AccordionDetails>
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
              {!showSlidingScale && <div>
                <label className='checkbox-container'>
                  <Checkbox
                    onChange={handleSponsorStudentCheckbox}
                    disabled={showPaymentButtons}
                    color='default'
                  />
                  <span className='checkbox-label' id='sponsor-a-student'>I would like to sponsor a Student's membership for just ${totalStudentMembershipPrice} more</span>
                </label>
              </div>}

              {!sponsorStudent && <>
                {offerSlidingScaleMembershipPricing && totalRdMembershipPrice > minimumSlidingScaleRdMembershipPrice && <div>
                  <label className='checkbox-container'>
                    <Checkbox onChange={handleSlidingScaleCheckbox} disabled={showPaymentButtons} color='default' />
                    <span className='checkbox-label' id='sliding-scale'>I would like to (anonymously) pay less than ${totalRdMembershipPrice}</span>
                  </label>
                </div>}
                {showSlidingScale &&
                <div className='sliding-scale-price-slider'>
                  <label className='checkbox-label'>Choose an amount ${minimumSlidingScaleRdMembershipPrice} - ${totalRdMembershipPrice}</label>
                  <Slider
                    defaultValue={totalRdMembershipPrice}
                    step={1}
                    min={minimumSlidingScaleRdMembershipPrice}
                    max={totalRdMembershipPrice}
                    onChange={handleSlidingScalePriceChange}
                    marks={[
                      {
                        value: minimumSlidingScaleRdMembershipPrice,
                        label: `$${minimumSlidingScaleRdMembershipPrice}`
                      },
                      {
                        value: totalRdMembershipPrice,
                        label: `$${totalRdMembershipPrice}`
                      }
                    ]}
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
        </AccordionDetails>
      </Accordion>

      <Accordion disabled={!showPaymentButtons || paymentCompleted} expanded={showPaymentButtons && !paymentCompleted}>
        <AccordionSummary>
          <div>Step 2: Payment Information</div>
        </AccordionSummary>
        <AccordionDetails>
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
        </AccordionDetails>
      </Accordion>

      <Accordion disabled={!paymentCompleted} expanded={paymentCompleted}>
        <AccordionSummary>
          <div>Step 3: Membership Confirmation</div>
        </AccordionSummary>
        <AccordionDetails>
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
        </AccordionDetails>
      </Accordion>
    </>
  )
}

const { bool, number, shape, string } = PropTypes;

Registration.propTypes = {
  clientAuthtoken: string.isRequired,
  rdMembershipPrice: number,
  studentMembershipPrice: number,
  offerSlidingScaleMembershipPricing: bool,
  minimumSlidingScaleRdMembershipPrice: number,
  rdMembershipDiscount: shape({
    discount_amount_in_dollars: number,
    discount_end_date: string,
  }).isRequired,
  studentMembershipDiscount: shape({
    discount_amount_in_dollars: number,
    discount_end_date: string,
  }).isRequired,
};

Registration.defaultProps = {
  rdMembershipPrice: 35,
  studentMembershipPrice: 10,
  offerSlidingScaleMembershipPricing: false,
  minimumSlidingScaleRdMembershipPrice: 20,
};

export default Registration;
