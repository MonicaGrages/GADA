import 'core-js';
import PropTypes from 'prop-types';
import React, { useEffect, useState } from 'react';
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
import { calculateTotalCost, formattedPayPalFee } from 'helpers/feeCalculator';
import { apiRequests } from 'helpers/apiRequests';
import { MEMBERSHIP_TYPE_DISPLAY_NAMES } from 'components/Registration/constants';

const Registration = ({
  clientAuthtoken,
  offerSlidingScaleMembershipPricing,
  minimumSlidingScaleRdMembershipPrice,
  rdMembershipDiscount,
  studentMembershipDiscount,
  membershipPrices,
  offerStudentSponsorship,
}) => {
  const apiClient = apiRequests(clientAuthtoken);

  const determineDiscountedRdMembershipPrice = () => {
    if(!rdMembershipDiscount.discount_amount_in_dollars) return;

    return membershipPrices.rd - rdMembershipDiscount.discount_amount_in_dollars;
  }

  const determineDiscountedStudentMembershipPrice = () => {
    if(!studentMembershipDiscount.discount_amount_in_dollars) return;

    return membershipPrices.student - studentMembershipDiscount.discount_amount_in_dollars;
  };

  const discountedRdMembershipPrice = determineDiscountedRdMembershipPrice();
  const totalRdMembershipPrice = discountedRdMembershipPrice || membershipPrices.rd;

  const discountedStudentMembershipPrice = determineDiscountedStudentMembershipPrice();
  const totalStudentMembershipPrice = discountedStudentMembershipPrice || membershipPrices.student;

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

  useEffect(() => {
    setMembershipPrice(calculatePrice());
  }, [membershipType, sponsorStudent, slidingScalePrice]);

  const calculatePrice = () => {
    if (!membershipType) return;
    if (membershipType === 'student') return totalStudentMembershipPrice;

    const price = membershipPrices[membershipType];
    if (sponsorStudent) return price + totalStudentMembershipPrice;
    if (showSlidingScale) return slidingScalePrice;
    return price;
  }

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
      const response = await apiClient.get(`/api/members/search?email=${email}`);

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

    return await apiClient.post('/api/members', params);
  };

  return (
    <>
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
                {Object.keys(membershipPrices).map((key) => {
                  return(
                    <FormControlLabel
                      value={key}
                      control={<Radio color='default' disabled={showPaymentButtons} />}
                      label={MEMBERSHIP_TYPE_DISPLAY_NAMES[key]}
                      id={key}
                    />
                  )
                })}
              </RadioGroup>
            </div>

            {membershipType === 'rd' && <>
              {offerStudentSponsorship && !showSlidingScale && <div>
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
                {membershipType === 'rd' && offerSlidingScaleMembershipPricing && totalRdMembershipPrice > minimumSlidingScaleRdMembershipPrice && <div>
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

            {membershipPrice && <h5 className='header light'>Membership Price: ${membershipPrice}</h5>}
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
            <h6 className='header light'>Membership Price: ${membershipPrice}</h6>
            <h6 className='header light'>PayPal Fee: ${formattedPayPalFee(membershipPrice)}</h6>
            <h5 className='header light'>Total: ${calculateTotalCost(membershipPrice)}</h5>
            <PayPalButtons
              membershipType={membershipType}
              totalPrice={calculateTotalCost(membershipPrice)}
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

            <h6 className='center header light teal-text'>The GADA membership year runs from September 1 to August 31.</h6>

            <h6 className='center header light'>You can confirm the status of your membership at any time
              <a href='/member_search' className='teal-text bold-text'> <b>here</b></a>.
            </h6>

            {/*<h6 className='header center'>You can also check out our upcoming*/}
            {/*  <b><a href='/events' className='green-text'> events</a></b>, read our*/}
            {/*  <b><a href='/blogs' className='blue-text'> blog</a></b>, and get to know your*/}
            {/*  <b><a href='/board_members' className='orange-text'> board members</a></b>.*/}
            {/*</h6>*/}

            <h6 className='header center'>
              If you have any questions about GADA or your membership, don't hesitate to
              <b><a className='red-text' href='mailto:gadainfo@gadaatl.org'> email us.</a></b>
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
  offerStudentSponsorship: bool,
  membershipPrices: shape({
    rd: number,
    student: number,
    dtr: number,
    retired: number,
    subscriber: number,
  }),
};

Registration.defaultProps = {
  offerSlidingScaleMembershipPricing: false,
  minimumSlidingScaleRdMembershipPrice: 20,
  offerStudentSponsorship: false,
  membershipPrices: {
    rd: 35,
    student: 10,
    dtr: 25,
    retired: 30,
    subscriber: 40,
  }
};

export default Registration;
