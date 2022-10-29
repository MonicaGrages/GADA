import axios from 'axios';

export function apiRequests (clientAuthtoken) {
  const tokenElement = document.querySelector("meta[name='csrf-token']");
  const csrf = tokenElement && tokenElement.getAttribute("content");
  axios.defaults.headers.common['X-CSRF-TOKEN'] = csrf;
  axios.defaults.headers.common['Content-Type'] = 'application/json';
  axios.defaults.headers.common['X-Auth-Token'] = clientAuthtoken;

  return axios;
}
