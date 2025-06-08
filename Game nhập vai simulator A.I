import React, { useState, useEffect, useCallback, useRef } from 'react';
import { initializeApp } from 'firebase/app';
import { getAuth, signInAnonymously, onAuthStateChanged, signInWithCustomToken } from 'firebase/auth';
import { getFirestore, doc, setDoc, getDoc, collection, addDoc, getDocs, updateDoc, deleteDoc, serverTimestamp, onSnapshot, query, where } from 'firebase/firestore';

// Icons
const PlayIcon = () => <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" className="w-6 h-6 mr-2"><path fillRule="evenodd" d="M4.5 5.653c0-1.427 1.529-2.33 2.779-1.643l11.54 6.347c1.295.712 1.295 2.573 0 3.286L7.28 19.99c-1.25.687-2.779-.217-2.779-1.643V5.653Z" clipRule="evenodd" /></svg>;
const CogIcon = () => <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" className="w-5 h-5 mr-2"><path fillRule="evenodd" d="M11.078 2.25c-.917 0-1.699.663-1.905 1.523L9.017 8.429a1.875 1.875 0 0 1-.445 1.035l-2.833 2.833a1.875 1.875 0 0 0 0 2.652l2.833 2.833c.28.28.626.445.994.445s.714-.165.994-.445l2.832-2.833a1.875 1.875 0 0 1 1.036-.445l4.906-.153c.94-.03 1.686-.786 1.686-1.727V9.28c0-.94-.747-1.697-1.686-1.727l-4.906-.153a1.875 1.875 0 0 1-1.036-.445l-2.832-2.833A1.875 1.875 0 0 0 11.078 2.25ZM12.75 9a3.75 3.75 0 1 0 0 7.5 3.75 3.75 0 0 0 0-7.5Z" clipRule="evenodd" /></svg>;
const SaveIcon = () => <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" className="w-5 h-5 mr-2"><path d="M3.375 3C2.339 3 1.5 3.84 1.5 4.875v14.25C1.5 20.16 2.339 21 3.375 21h17.25c1.035 0 1.875-.84 1.875-1.875V4.875C22.5 3.839 21.66 3 20.625 3H3.375Z" /><path d="M9 3.75a.75.75 0 0 1 .75.75v4.5a.75.75 0 0 1-1.5 0v-4.5A.75.75 0 0 1 9 3.75Zm6.75 0a.75.75 0 0 1 .75.75v4.5a.75.75 0 0 1-1.5 0v-4.5a.75.75 0 0 1 .75-.75Z" /></svg>;
const CheckIcon = () => <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" className="w-5 h-5 mr-2"><path fillRule="evenodd" d="M19.916 4.626a.75.75 0 0 1 .208 1.04l-9 13.5a.75.75 0 0 1-1.154.114l-6-6a.75.75 0 0 1 1.06-1.06l5.353 5.353 8.493-12.74a.75.75 0 0 1 1.04-.207Z" clipRule="evenodd" /></svg>;
const ArrowPathIcon = () => <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" className="w-5 h-5 mr-2"><path fillRule="evenodd" d="M4.755 10.059a7.5 7.5 0 0 1 12.548-3.364l1.903 1.903h-4.5a.75.75 0 0 0 0 1.5h6a.75.75 0 0 0 .75-.75V4.5a.75.75 0 0 0-1.5 0v2.72a9 9 0 1 0-10.713 9.926.75.75 0 0 0 1.214-.882A7.474 7.474 0 0 1 5.353 10.5H4.755Z" clipRule="evenodd" /></svg>;
const PlusCircleIcon = () => <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" className="w-6 h-6 mr-2"><path fillRule="evenodd" d="M12 2.25c-5.385 0-9.75 4.365-9.75 9.75s4.365 9.75 9.75 9.75 9.75-4.365 9.75-9.75S17.385 2.25 12 2.25ZM12.75 9a.75.75 0 0 0-1.5 0v2.25H9a.75.75 0 0 0 0 1.5h2.25V15a.75.75 0 0 0 1.5 0v-2.25H15a.75.75 0 0 0 0-1.5h-2.25V9Z" clipRule="evenodd" /></svg>;
const ArrowLeftStartOnRectangleIcon = () => <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" className="w-5 h-5 mr-1"><path fillRule="evenodd" d="M12 2.25c-5.385 0-9.75 4.365-9.75 9.75s4.365 9.75 9.75 9.75 9.75-4.365 9.75-9.75S17.385 2.25 12 2.25Zm-2.625 6c-.54 0-.828.419-.936.634a1.96 1.96 0 0 0-.189.866c0 .298.012.626.035.95.023.324.075.72.14 1.062.066.34.152.673.253.97.102.296.223.543.358.745.136.201.287.34.45.425.164.086.342.12.524.12.182 0 .36-.034.524-.12a1.32 1.32 0 0 0 .45-.425c.135-.202.256-.449.357-.745.101-.297.187-.63.253-.97.065-.342.117-.738.14-1.062.023-.324.035-.652.035-.95a1.96 1.96 0 0 0-.189-.866c-.108-.215-.396-.634-.936-.634H9.375Z" clipRule="evenodd" /></svg>;
const InformationCircleIcon = ({className = "w-6 h-6 mr-2 text-blue-400"}) => <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" className={className}><path fillRule="evenodd" d="M2.25 12c0-5.385 4.365-9.75 9.75-9.75s9.75 4.365 9.75 9.75-4.365 9.75-9.75 9.75S2.25 17.385 2.25 12Zm8.706-1.442c1.146-.573 2.437.463 2.126 1.706l-.709 2.836.042-.02a.75.75 0 0 1 .67 1.34l-.04.022c-1.147.573-2.438-.463-2.127-1.706l.71-2.836-.042.02a.75.75 0 1 1-.671-1.34l.041-.022ZM12 9a.75.75 0 1 0 0-1.5.75.75 0 0 0 0 1.5Z" clipRule="evenodd" /></svg>;
const ExclamationTriangleIcon = ({className = "w-6 h-6 mr-2 text-yellow-400"}) => <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" className={className}><path fillRule="evenodd" d="M9.401 3.003c1.155-2 4.043-2 5.197 0l7.519 13.007c1.155 2-.772 4.5-3.298 4.5H5.18c-2.526 0-4.453-2.5-3.298-4.5L9.4 3.003ZM12 8.25a.75.75 0 0 1 .75.75v3.75a.75.75 0 0 1-1.5 0V9a.75.75 0 0 1 .75-.75Zm0 8.25a.75.75 0 1 0 0-1.5.75.75 0 0 0 0 1.5Z" clipRule="evenodd" /></svg>;
const UserCircleIcon = () => <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" className="w-6 h-6 mr-2 text-sky-400"><path fillRule="evenodd" d="M18.685 19.097A9.723 9.723 0 0 0 21.75 12c0-5.385-4.365-9.75-9.75-9.75S2.25 6.615 2.25 12a9.723 9.723 0 0 0 3.065 7.097A9.716 9.716 0 0 0 12 21.75a9.716 9.716 0 0 0 6.685-2.653Zm-12.54-1.285A7.486 7.486 0 0 1 12 15a7.486 7.486 0 0 1 5.855 2.812A8.224 8.224 0 0 1 12 20.25a8.224 8.224 0 0 1-5.855-2.438ZM15.75 9a3.75 3.75 0 1 1-7.5 0 3.75 3.75 0 0 1 7.5 0Z" clipRule="evenodd" /></svg>;
const SparklesIcon = ({className = "w-4 h-4"}) => <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className={className}><path fillRule="evenodd" d="M10.868 2.884c-.321-.772-1.415-.772-1.736 0l-1.83 4.401-4.753.39-3.423 3.11a.75.75 0 0 0 .44 1.316l4.861 1.214 1.83 4.401c.321.772 1.415.772 1.736 0l1.83-4.401 4.753-.39 3.423-3.11a.75.75 0 0 0-.44-1.316l-4.861-1.214-1.83-4.401Z" clipRule="evenodd" /></svg>;
const LightBulbIcon = ({className = "w-5 h-5 mr-1"}) => <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" className={className}><path d="M12 2.25a.75.75 0 0 1 .75.75v2.519c.04.004.079.008.118.012l.001.001.001.001a4.499 4.499 0 0 1 3.02 3.895C16.5 10.5 18 12 18 13.5V15a1.5 1.5 0 0 1-1.5 1.5H7.5A1.5 1.5 0 0 1 6 15v-1.5c0-1.5 1.5-3 2.092-3.824A4.499 4.499 0 0 1 11.13 5.53l.001-.001.001-.001.118-.012V3a.75.75 0 0 1 .75-.75Zm4.525 15.75a.75.75 0 0 0-.75.75 3 3 0 0 1-6 0 .75.75 0 0 0-.75-.75h-.496a.75.75 0 0 0 0 1.5h.496c.21 1.204 1.256 2.142 2.492 2.241A2.252 2.252 0 0 0 12 21.75a2.252 2.252 0 0 0 2.242-.759c1.236-.1 2.281-1.037 2.492-2.241h.496a.75.75 0 0 0 0-1.5h-.496Z" /></svg>;
const UserGroupIcon = ({className="w-5 h-5 mr-2"}) => <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" className={className}><path d="M4.5 6.375a.75.75 0 0 1 .75-.75h2.25a.75.75 0 0 1 0 1.5H5.25a.75.75 0 0 1-.75-.75Z" /><path fillRule="evenodd" d="M5.25 7.5A2.25 2.25 0 0 1 3 5.25v-1.5A2.25 2.25 0 0 1 5.25 1.5h13.5A2.25 2.25 0 0 1 21 3.75v1.5A2.25 2.25 0 0 1 18.75 7.5h-1.5a.75.75 0 0 1 0-1.5h1.5a.75.75 0 0 0 .75-.75v-1.5a.75.75 0 0 0-.75-.75H5.25a.75.75 0 0 0-.75.75v1.5c0 .414.336.75.75.75Zm2.03 4.72a.75.75 0 0 1 1.06 0l.97.97a.75.75 0 1 1-1.06 1.06l-.97-.97a.75.75 0 0 1 0-1.06Zm-2.25 2.25a.75.75 0 0 0 0 1.06l.97.97a.75.75 0 1 0 1.06-1.06l-.97-.97a.75.75 0 0 0-1.06 0Z" clipRule="evenodd" /><path d="M12.75 11.625a.75.75 0 0 0-1.5 0v6.75a.75.75 0 0 0 1.5 0v-6.75Z" /><path d="M14.25 12.375a.75.75 0 0 1 .75-.75h2.25a.75.75 0 0 1 0 1.5H15a.75.75 0 0 1-.75-.75Z" /><path fillRule="evenodd" d="M15 13.5A2.25 2.25 0 0 1 12.75 11.25v-1.5A2.25 2.25 0 0 1 15 7.5h3.75A2.25 2.25 0 0 1 21 9.75v1.5A2.25 2.25 0 0 1 18.75 13.5h-1.5a.75.75 0 0 1 0-1.5h1.5a.75.75 0 0 0 .75-.75v-1.5a.75.75 0 0 0-.75-.75H15a.75.75 0 0 0-.75.75v1.5c0 .414.336.75.75.75Zm-2.03 4.72a.75.75 0 0 1 1.06 0l.97.97a.75.75 0 0 1-1.06 1.06l-.97-.97a.75.75 0 0 1 0-1.06Zm-2.25 2.25a.75.75 0 0 0 0 1.06l.97.97a.75.75 0 1 0 1.06-1.06l-.97-.97a.75.75 0 0 0-1.06 0Z" clipRule="evenodd" /><path d="M5.25 12.375a.75.75 0 0 1 .75-.75h2.25a.75.75 0 0 1 0 1.5H6a.75.75 0 0 1-.75-.75Z" /><path fillRule="evenodd" d="M6 13.5A2.25 2.25 0 0 1 3.75 11.25v-1.5A2.25 2.25 0 0 1 6 7.5h3.75A2.25 2.25 0 0 1 12 9.75v1.5A2.25 2.25 0 0 1 9.75 13.5H8.25a.75.75 0 0 1 0-1.5h1.5a.75.75 0 0 0 .75-.75v-1.5a.75.75 0 0 0-.75-.75H6a.75.75 0 0 0-.75.75v1.5c0 .414.336.75.75.75Z" clipRule="evenodd" /></svg>;
const PlusIcon = ({className="w-5 h-5"}) => <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className={className}><path d="M10.75 4.75a.75.75 0 0 0-1.5 0v4.5h-4.5a.75.75 0 0 0 0 1.5h4.5v4.5a.75.75 0 0 0 1.5 0v-4.5h4.5a.75.75 0 0 0 0-1.5h-4.5v-4.5Z" /></svg>;
const TrashIcon = ({className="w-5 h-5"}) => <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" className={className}><path fillRule="evenodd" d="M8.75 1A2.75 2.75 0 0 0 6 3.75v.443c-.795.077-1.58.177-2.34.297A1.875 1.875 0 0 0 2.05 6.22l.83 9.126A3.375 3.375 0 0 0 6.199 18.75h7.602a3.375 3.375 0 0 0 3.319-3.398l.83-9.126a1.875 1.875 0 0 0-1.61-1.731c-.76-.12-1.546-.22-2.34-.297V3.75A2.75 2.75 0 0 0 11.25 1h-2.5ZM7.5 3.75c0-.69.56-1.25 1.25-1.25h2.5c.69 0 1.25.56 1.25 1.25V4h-5V3.75Z" clipRule="evenodd" /></svg>;
const BuildingStorefrontIcon = ({className="w-5 h-5 mr-2"}) => <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" className={className}><path d="M12 2.25c-5.385 0-9.75 4.365-9.75 9.75s4.365 9.75 9.75 9.75 9.75-4.365 9.75-9.75S17.385 2.25 12 2.25Z" /><path d="M6.262 6.072a8.25 8.25 0 0 1 11.477 0 7.5 7.5 0 0 1 0 11.855.75.75 0 0 0 .36.968l1.43 1.072a.75.75 0 0 0 .968-.36 8.25 8.25 0 0 0-11.477 0 .75.75 0 0 0 .968.36l1.43-1.072a.75.75 0 0 0 .36-.968 7.5 7.5 0 0 1 0-11.856Z" /></svg>;
const BackpackIcon = ({className="w-5 h-5 mr-1"}) => <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" className={className}><path fillRule="evenodd" d="M8.25 1.5A2.25 2.25 0 0 0 6 3.75v16.5A2.25 2.25 0 0 0 8.25 22.5h7.5A2.25 2.25 0 0 0 18 20.25V3.75A2.25 2.25 0 0 0 15.75 1.5h-7.5ZM9 3a.75.75 0 0 0 0 1.5h6A.75.75 0 0 0 15 3H9Z" clipRule="evenodd" /></svg>;
const BoltIcon = ({className="w-5 h-5 mr-1"}) => <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" className={className}><path fillRule="evenodd" d="M11.278 2.232a.75.75 0 0 1 .444 0l9 5.25a.75.75 0 0 1 0 1.316l-7.16 4.177a.75.75 0 0 1-.722 0L4.68 9.316a1.5 1.5 0 0 0-1.5.715L2.25 12a.75.75 0 0 0 .888.933l.003-.001a.75.75 0 0 1 .444 0l9 5.25a.75.75 0 0 1 0 1.316l-7.16 4.177a.75.75 0 0 1-.722 0L2.28 19.498a.75.75 0 0 1-.03-.018A.75.75 0 0 1 3 18.75v-5.25a.75.75 0 0 1 .375-.65l6.375-3.72V6.75a.75.75 0 0 1-.375-.65L3 2.384A.75.75 0 0 1 3.375 1.5H4.5a.75.75 0 0 1 .658.397l.003.003L7.44 3.75l1.68-1.023a.75.75 0 0 1 .678-.075l.02.01.005.002.002.001.001.001.001.001c.003 0 .003 0 .003-.001a.753.753 0 0 1 .042-.021l1.43-.833ZM12.75 12.19l4.5-2.625L12.75 7v5.19ZM11.25 7l-4.5 2.625L11.25 12.19V7Z" clipRule="evenodd" /></svg>;
const HeartIcon = ({className="w-5 h-5 mr-1"}) => <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" className={className}><path d="M11.645 20.91a.75.75 0 0 1-1.29 0A18.377 18.377 0 0 1 4.5 9.285c0-3.995 3.05-7.285 6.75-7.285 1.74 0 3.341.81 4.5 2.125 1.159-1.315 2.76-2.125 4.5-2.125 3.7 0 6.75 3.29 6.75 7.285 0 3.071-1.703 6.082-5.234 9.335A18.377 18.377 0 0 1 11.645 20.91Z" /></svg>;
const CharacterSheetIcon = ({className="w-5 h-5 mr-1"}) => <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" className={className}><path d="M5.625 1.5c-1.036 0-1.875.84-1.875 1.875v17.25c0 1.035.84 1.875 1.875 1.875h12.75c1.035 0 1.875-.84 1.875-1.875V12.75A3.75 3.75 0 0 0 16.5 9h-1.875a.375.375 0 0 1-.375-.375V6.75A3.75 3.75 0 0 0 10.5 3H5.625Z" /><path d="M12.75 3H10.5a.75.75 0 0 0-.75.75v3c0 .414.336.75.75.75h3c.414 0 .75-.336.75-.75v-3a.75.75 0 0 0-.75-.75Z" /><path d="M12.75 12.75h3.75a.75.75 0 0 0 .75-.75V9.375a.75.75 0 0 0-.75-.75h-3.75a.75.75 0 0 0-.75.75v2.625c0 .414.336.75.75.75Z" /></svg>;
const FaceSmileIcon = ({className="w-5 h-5 mr-1"}) => <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" className={className}><path fillRule="evenodd" d="M12 2.25c-5.385 0-9.75 4.365-9.75 9.75s4.365 9.75 9.75 9.75 9.75-4.365 9.75-9.75S17.385 2.25 12 2.25Zm-2.055 9.995a.75.75 0 0 0 1.06 1.061L12 12.25l.995 1.06a.75.75 0 0 0 1.06-1.06L13.06 11.25l1.06-.995a.75.75 0 1 0-1.06-1.06L12 10.19l-.995-1.06a.75.75 0 0 0-1.06 1.06l1.06.995-1.06.995Zm3.035-2.478a.75.75 0 0 0-1.02-.096 9.096 9.096 0 0 0-3.93 0 .75.75 0 0 0-1.02.096 7.483 7.483 0 0 0-2.024 5.115c-.04.33.22.615.55.615h10.818c.33 0 .59-.284.55-.615a7.483 7.483 0 0 0-2.024-5.115Z" clipRule="evenodd" /></svg>;
const BullseyeIcon = ({className="w-5 h-5 mr-1 text-red-400"}) => <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" className={className}><path fillRule="evenodd" d="M12 2.25c-5.385 0-9.75 4.365-9.75 9.75s4.365 9.75 9.75 9.75 9.75-4.365 9.75-9.75S17.385 2.25 12 2.25ZM12.75 6a.75.75 0 0 0-1.5 0v6c0 .414.336.75.75.75s.75-.336.75-.75V6ZM12 15a.75.75 0 0 1 .75.75v.008c0 .414-.336.75-.75.75s-.75-.336-.75-.75V15.75A.75.75 0 0 1 12 15Z" clipRule="evenodd" /></svg>;
const HeartCrackIcon = ({className="w-5 h-5 mr-1"}) => <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" className={className}><path d="m11.645 20.91-1.008-1.008c-5.633-5.633-8.38-9.115-8.38-12.354C2.257 4.092 5.092 1.5 8.25 1.5c1.818 0 3.515.887 4.633 2.317l.117-.117a.75.75 0 0 1 1.06 1.06l-1.06 1.06.06.06a5.25 5.25 0 0 1 4.196 2.002l1.086 1.086-7.424 7.424a.75.75 0 0 0-.22.53V16.5a.75.75 0 0 1-.75.75h-2.25a.75.75 0 0 0-.53.22L9 18.168l-3.47-3.47a.75.75 0 0 1 0-1.06Z" /><path d="M12.963 2.317A5.23 5.23 0 0 0 8.25 1.5C5.092 1.5 2.257 4.092 2.257 7.543c0 3.24 2.747 6.721 8.38 12.354l1.008 1.008a.75.75 0 0 0 1.29-.001l6.737-6.737a5.252 5.252 0 0 0 .218-7.963 5.202 5.202 0 0 0-4.196-2.002 5.175 5.175 0 0 0-3.731 1.568l-.001.001Z" /></svg>; 
const ShieldCheckIcon = ({className="w-5 h-5 mr-1"}) => <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" className={className}><path fillRule="evenodd" d="M12.75 2.239c.204-.063.419-.063.622 0l8.25 2.526c.07.021.136.05.2.084a1.124 1.124 0 0 1 .602 1.01V12c0 5.084-3.158 9.734-7.752 11.563a.75.75 0 0 1-.642 0C8.658 21.734 5.5 17.084 5.5 12V5.86c0-.39.223-.748.552-.926.068-.036.136-.064.203-.084L12.75 2.24ZM11.25 16.12l7.22-7.22a.75.75 0 0 0-1.06-1.06l-6.69 6.69-2.72-2.72a.75.75 0 0 0-1.06 1.06l3.25 3.25a.75.75 0 0 0 1.06 0Z" clipRule="evenodd" /></svg>; 
const MegaphoneIcon = ({className = "w-5 h-5 mr-2"}) => <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" className={className}><path d="M10.5 1.5H5.25A2.25 2.25 0 0 0 3 3.75v16.5A2.25 2.25 0 0 0 5.25 22.5h13.5A2.25 2.25 0 0 0 21 20.25V10.5A2.25 2.25 0 0 0 18.75 8.25h-3.573L13.5 4.577A2.25 2.25 0 0 0 10.5 1.5ZM5.625 15.75a.75.75 0 0 1 .75-.75h11.25a.75.75 0 0 1 0 1.5H6.375a.75.75 0 0 1-.75-.75Zm0-3a.75.75 0 0 1 .75-.75h11.25a.75.75 0 0 1 0 1.5H6.375a.75.75 0 0 1-.75-.75Zm0-3a.75.75 0 0 1 .75-.75H12a.75.75 0 0 1 0 1.5H6.375a.75.75 0 0 1-.75-.75Z" /><path d="M12.75 6a.75.75 0 0 0-1.5 0v1.5h-1.5a.75.75 0 0 0 0 1.5h1.5v1.5a.75.75 0 0 0 1.5 0v-1.5h1.5a.75.75 0 0 0 0-1.5h-1.5V6Z" /></svg>;
const ClipboardDocumentCheckIcon = ({className = "w-5 h-5 mr-1"}) => <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" className={className}><path fillRule="evenodd" d="M10.5 3A2.25 2.25 0 0 0 8.25 5.25v2.036a3.001 3.001 0 0 1 .368.258l3.75 2.25a1.875 1.875 0 0 1 0 3.194l-3.75 2.25a3.001 3.001 0 0 1-.368.258V18.75A2.25 2.25 0 0 0 10.5 21h6A2.25 2.25 0 0 0 18.75 18.75V5.25A2.25 2.25 0 0 0 16.5 3h-6Zm5.03 4.72a.75.75 0 0 0-1.06-1.06l-1.72 1.72-1.72-1.72a.75.75 0 0 0-1.06 1.06L11.94 9 9.72 11.22a.75.75 0 1 0 1.06 1.06L13 10.06l2.22 2.22a.75.75 0 1 0 1.06-1.06L14.06 9l2.22-2.22Z" clipRule="evenodd" /><path d="M3.75 6A2.25 2.25 0 0 0 1.5 8.25v10.5A2.25 2.25 0 0 0 3.75 21H5.25V18.75a3.75 3.75 0 0 1 3.75-3.75h.75V9.563a4.501 4.501 0 0 0-.099-.728A.75.75 0 0 1 9.375 8.25H3.75Z" /></svg>;

// Firebase Config
const firebaseConfig = typeof __firebase_config !== 'undefined' ? JSON.parse(__firebase_config) : {
  apiKey: "YOUR_FALLBACK_API_KEY", 
  authDomain: "YOUR_FALLBACK_AUTH_DOMAIN",
  projectId: "YOUR_FALLBACK_PROJECT_ID",
  storageBucket: "YOUR_FALLBACK_STORAGE_BUCKET",
  messagingSenderId: "YOUR_FALLBACK_MESSAGING_SENDER_ID",
  appId: "YOUR_FALLBACK_APP_ID"
};

const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = getFirestore(app);
const appId = typeof __app_id !== 'undefined' ? __app_id : 'ai-text-adventure-simulator-vn';

// Changelog Data
const changelogData = [
    {
        version: "2.0 (Nhiệm Vụ & Cải Tiến AI)",
        date: "02/06/2025",
        changes: [
            "THÊM MỚI: Hệ thống Nhiệm Vụ (Quest)! AI giờ đây có thể giao nhiệm vụ, theo dõi tiến độ và nhiệm vụ sẽ ảnh hưởng đến cốt truyện.",
            "THÊM MỚI: Mục 'Nhật Ký Nhiệm Vụ' trong Thông Tin Nhân Vật để xem các nhiệm vụ đang hoạt động và đã hoàn thành.",
            "THÊM MỚI: Mục 'Cập Nhật Trò Chơi' để xem các thay đổi mới nhất.",
            "CẢI TIẾN AI: Tăng cường khả năng AI ghi nhớ và duy trì tính liên tục của câu chuyện, bám sát hơn vào bối cảnh, nhân vật, và các sự kiện đã diễn ra.",
            "CẢI TIẾN AI: AI sẽ cố gắng hơn trong việc phản ánh tính cách và mục tiêu của nhân vật trong các diễn biến và lựa chọn.",
            "CẢI TIẾN GIAO DIỆN: Điều chỉnh nhỏ về giao diện và thêm các biểu tượng mới.",
        ],
    },
    {
        version: "1.9 (AI Gợi Ý & Giao Diện)",
        date: "Trước đó",
        changes: [
            "Thêm tính năng AI gợi ý Tên Nhân Vật, Kỹ Năng Khởi Đầu, Mục Tiêu, Tiểu Sử, Mô Tả Độ Khó, Mô Tả Thực Thể Ban Đầu.",
            "Cải tiến giao diện màn hình thiết lập game, thêm nhiều biểu tượng và sắp xếp lại các mục.",
            "Thêm tùy chọn 'Thực Thể Ban Đầu' để người chơi kiến tạo thế giới chi tiết hơn.",
            "Cải thiện cơ chế lưu/tải game và thiết lập API Key.",
        ],
    },
];


// Helper Functions
function parseKeyValueString(kvString) {
    const result = {};
    // Regex này cố gắng bắt các cặp key=value, với value có thể nằm trong dấu nháy kép, nháy đơn, hoặc là một chuỗi không có dấu nháy (nhưng không chứa dấu phẩy nếu theo sau là một key khác)
    // Nó cũng hỗ trợ các ký tự tiếng Việt có dấu.
    const pairRegex = /([\w\u00C0-\u017F\s]+)\s*=\s*(?:"([^"]*)"|'([^']*)'|([\w\u00C0-\u017F\s\d.:\/+\-_%À-ỹ]+?(?=\s*,\s*[\w\u00C0-\u017F\s]+\s*=|$)))/gu;
    let match;
    while ((match = pairRegex.exec(kvString)) !== null) {
        const key = match[1].trim();
        // Ưu tiên giá trị trong dấu nháy kép, rồi nháy đơn, rồi đến không có dấu nháy
        let value = match[2] || match[3] || match[4]; 
        if (value !== undefined) {
            const trimmedValue = value.trim();
            // Chuyển đổi sang boolean nếu là 'true'/'false'
            if (trimmedValue.toLowerCase() === 'true') {
                result[key] = true;
            } else if (trimmedValue.toLowerCase() === 'false') {
                result[key] = false;
            } 
            // Chuyển đổi sang số nếu là số (bao gồm cả số thập phân)
            else if (/^\d+(\.\d+)?$/.test(trimmedValue) && !isNaN(parseFloat(trimmedValue))) {
                result[key] = parseFloat(trimmedValue);
            } else {
                result[key] = trimmedValue;
            }
        }
    }
    return result;
}

const PLAYER_PERSONALITIES = [
    // Positive / Neutral Traits
    "Dũng Cảm, Bộc Trực", "Thận Trọng, Đa Nghi", "Lạnh Lùng, Ít Nói", "Hài Hước, Thích Trêu Chọc",
    "Nhân Hậu, Vị Tha", "Trầm Tính, Thích Quan Sát", "Nhút Nhát, Hay Lo Sợ", "Tò Mò, Thích Khám Phá",
    "Trung Thành, Đáng Tin Cậy", "Lãng Mạn, Mơ Mộng", "Thực Dụng, Coi Trọng Lợi Ích", "Chính Trực, Ghét Sự Giả Dối",
    "Hoài Nghi, Luôn Đặt Câu Hỏi", "Lạc Quan, Luôn Nhìn Về Phía Trước", "Lý Trí, Giỏi Phân Tích",
    "Nghệ Sĩ, Tâm Hồn Bay Bổng", "Thích Phiêu Lưu, Không Ngại Mạo Hiểm", "Cẩn Thận Từng Chi Tiết, Cầu Toàn",
    "Hào Sảng, Thích Giúp Đỡ Người Khác", "Kiên Định, Không Dễ Bỏ Cuộc", "Khiêm Tốn, Không Khoe Khoang",
    "Sáng Tạo, Nhiều Ý Tưởng Độc Đáo",
    // Negative / Complex Traits
    "Mưu Mẹo, Gian Xảo", "Tham Lam, Ích Kỷ", "Khó Lường, Bí Ẩn", "Nóng Nảy, Liều Lĩnh",
    "Kiêu Ngạo, Tự Phụ", "Đa Sầu Đa Cảm, Dễ Tổn Thương", "Cố Chấp, Bảo Thủ", "Lười Biếng, Thích Hưởng Thụ",
    "Ghen Tị, Hay So Sánh", "Thù Dai, Khó Tha Thứ", "Ba Phải, Không Có Chính Kiến"
];


// UI Component Definitions

const InitialScreen = (props) => (
    <div className="flex flex-col items-center justify-center min-h-screen bg-gradient-to-br from-gray-900 to-gray-800 p-6">
      <h1 className="text-5xl font-bold text-transparent bg-clip-text bg-gradient-to-r from-purple-500 via-pink-500 to-orange-500 mb-12 text-center animate-pulse">
        Nhập Vai A.I Simulator
      </h1>
      <div className="space-y-4 w-full max-w-md"> {/* Reduced space-y for tighter buttons */}
        <button
          onClick={() => props.setCurrentScreen('setup')}
          className="w-full flex items-center justify-center bg-gradient-to-r from-purple-600 to-pink-600 hover:from-purple-700 hover:to-pink-700 text-white font-bold py-4 px-6 rounded-xl shadow-xl hover:shadow-2xl transition-all transform hover:scale-105 text-xl focus:outline-none focus:ring-4 focus:ring-pink-400 focus:ring-opacity-50"
        >
          <PlayIcon /> Bắt Đầu Cuộc Phiêu Lưu Mới
        </button>
        <button
          onClick={() => props.setShowLoadGameModal(true)}
          disabled={props.savedGames.length === 0}
          className="w-full flex items-center justify-center bg-gradient-to-r from-sky-500 to-cyan-500 hover:from-sky-600 hover:to-cyan-600 text-white font-semibold py-3 px-6 rounded-xl shadow-lg hover:shadow-xl transition-all transform hover:scale-105 text-lg disabled:from-gray-500 disabled:to-gray-600 disabled:cursor-not-allowed focus:outline-none focus:ring-4 focus:ring-cyan-400 focus:ring-opacity-50"
        >
          <SaveIcon /> Tải Game Đã Lưu ({props.savedGames.length})
        </button>
        <button
          onClick={() => props.setShowUpdateLogModal(true)}
          className="w-full flex items-center justify-center bg-gradient-to-r from-green-500 to-teal-500 hover:from-green-600 hover:to-teal-600 text-white font-semibold py-3 px-6 rounded-xl shadow-lg hover:shadow-xl transition-all transform hover:scale-105 text-lg focus:outline-none focus:ring-4 focus:ring-teal-400 focus:ring-opacity-50"
        >
          <MegaphoneIcon /> Xem Cập Nhật Game
        </button>
        <button
          onClick={() => { props.setInputApiKey(props.apiMode === 'userKey' ? props.apiKey : ''); props.setShowApiModal(true);}}
          className="w-full flex items-center justify-center bg-gray-700 hover:bg-gray-600 text-white font-semibold py-3 px-6 rounded-xl shadow-md hover:shadow-lg transition-all transform hover:scale-105 text-lg focus:outline-none focus:ring-4 focus:ring-gray-500 focus:ring-opacity-50"
        >
          <CogIcon /> Thiết Lập API Key
        </button>
      </div>
       <p className={`mt-6 text-sm ${props.apiKeyStatus.color}`}>{props.apiKeyStatus.status}: {props.apiKeyStatus.message}</p>
       {props.userId && <p className="mt-1 text-xs text-gray-400">UserID: {props.userId}</p>}
    </div>
  );

const UpdateLogModal = ({ show, onClose, changelog }) => {
    if (!show) return null;
    return (
        <div className="fixed inset-0 bg-black bg-opacity-75 flex items-center justify-center p-4 z-[110]">
            <div className="bg-gray-800 p-6 rounded-xl shadow-2xl w-full max-w-2xl max-h-[85vh] flex flex-col border border-green-600">
                <div className="flex items-center mb-4">
                    <MegaphoneIcon className="text-green-400 w-7 h-7 mr-2"/>
                    <h2 className="text-2xl font-semibold text-green-400">Cập Nhật Trò Chơi</h2>
                </div>
                <div className="overflow-y-auto flex-grow pr-2 scrollbar-thin scrollbar-thumb-green-500 scrollbar-track-gray-700 space-y-5">
                    {changelog.map((log, index) => (
                        <div key={index} className="bg-gray-700/70 p-4 rounded-lg shadow">
                            <h3 className="text-xl font-semibold text-teal-300">{log.version}</h3>
                            <p className="text-xs text-gray-400 mb-2">Ngày cập nhật: {log.date}</p>
                            <ul className="list-disc list-inside space-y-1 text-sm text-gray-200">
                                {log.changes.map((change, cIndex) => (
                                    <li key={cIndex}>{change}</li>
                                ))}
                            </ul>
                        </div>
                    ))}
                </div>
                <button
                    onClick={onClose}
                    className="mt-6 w-full bg-green-600 hover:bg-green-700 text-white font-semibold py-2.5 px-4 rounded-lg shadow hover:shadow-md transition-all"
                >
                    Đã Xem
                </button>
            </div>
        </div>
    );
};


const ApiSetupModal = ({ 
    inputApiKey, setInputApiKey, apiKeyStatus, saveApiKey, testApiKey, 
    isLoading, setShowApiModal, apiKey, setApiKeyStatus, apiMode, setApiMode,
    setModalMessage
}) => {
    const handleUseDefaultGemini = () => {
        setApiMode('defaultGemini');
        setInputApiKey(''); 
        setApiKeyStatus({ 
            status: 'Đang dùng Gemini AI Mặc Định', 
            message: 'Không cần API Key. Nội dung sẽ được tạo bởi AI của nền tảng.', 
            color: 'text-sky-400' 
        });
        setModalMessage({show: true, title: "Chế Độ AI Mặc Định", content: "Đã chuyển sang sử dụng Gemini AI mặc định. Ngươi không cần cung cấp API Key.", type: "success"});
    };

    return (
    <div className="fixed inset-0 bg-black bg-opacity-75 flex items-center justify-center p-4 z-50">
      <div className="bg-gray-800 p-8 rounded-xl shadow-2xl w-full max-w-lg transform transition-all">
        <h2 className="text-3xl font-semibold text-purple-400 mb-6">Thiết Lập Nguồn AI</h2>
        
        <button
            onClick={handleUseDefaultGemini}
            className={`w-full mb-4 flex items-center justify-center font-semibold py-3 px-4 rounded-lg shadow-md transition-colors
                        ${apiMode === 'defaultGemini' ? 'bg-sky-600 hover:bg-sky-700 text-white ring-2 ring-sky-400' : 'bg-gray-600 hover:bg-gray-500 text-gray-300'}`}
        >
            <SparklesIcon className="w-5 h-5 mr-2"/> Sử Dụng Gemini AI Mặc Định (Đề xuất)
        </button>
        
        <div className="my-2 text-center text-sm text-gray-400">Hoặc</div>

        <div>
            <label htmlFor="apiKeyInputModal" className={`block text-sm font-medium mb-1 ${apiMode === 'userKey' ? 'text-gray-300' : 'text-gray-500'}`}>
                Sử Dụng API Key Gemini Của Ngươi:
            </label>
            <input
                type="password"
                id="apiKeyInputModal"
                name="apiKeyInputModalName" 
                autoComplete="new-password" 
                value={inputApiKey}
                onChange={(e) => {
                    setInputApiKey(e.target.value);
                    if (apiMode !== 'userKey' && e.target.value.trim() !== '') {
                        setApiMode('userKey'); 
                         setApiKeyStatus({ status: 'Chưa cấu hình', message: 'Nhập API Key của bạn.', color: 'text-yellow-500' });
                    }
                }}
                placeholder="Nhập API Key của ngươi tại đây"
                className={`w-full p-3 bg-gray-700 border border-gray-600 rounded-lg text-white focus:ring-purple-500 focus:border-purple-500 ${apiMode !== 'userKey' ? 'opacity-50 cursor-not-allowed' : ''}`}
                disabled={apiMode !== 'userKey'}
            />
        </div>

        {apiMode === 'userKey' && (
            <>
                <div className={`my-3 text-sm ${apiKeyStatus.color}`}>{apiKeyStatus.status}: {apiKeyStatus.message}</div>
                <div className="flex flex-col sm:flex-row space-y-3 sm:space-y-0 sm:space-x-3 mt-3">
                <button
                    onClick={saveApiKey}
                    disabled={isLoading || !inputApiKey}
                    className="flex-1 flex items-center justify-center bg-green-600 hover:bg-green-700 text-white font-semibold py-3 px-4 rounded-lg shadow-md transition-colors disabled:bg-gray-500"
                >
                    <SaveIcon /> {isLoading ? 'Đang lưu...' : 'Lưu API Key'}
                </button>
                <button
                    onClick={testApiKey}
                    disabled={isLoading || !inputApiKey}
                    className="flex-1 flex items-center justify-center bg-blue-600 hover:bg-blue-700 text-white font-semibold py-3 px-4 rounded-lg shadow-md transition-colors disabled:bg-gray-500"
                >
                    <CheckIcon /> {isLoading ? 'Đang kiểm tra...' : 'Kiểm Tra API'}
                </button>
                </div>
            </>
        )}
         {apiMode === 'defaultGemini' && (
             <div className="my-3 text-sm text-sky-400">Đang sử dụng Gemini AI mặc định. Không cần lưu hay kiểm tra API Key.</div>
         )}

        <button
            onClick={() => { 
                setShowApiModal(false); 
                if (apiMode === 'userKey' && !apiKey) {
                     setApiKeyStatus({ status: 'Chưa cấu hình', message: 'Vui lòng nhập API Key của bạn.', color: 'text-yellow-500' });
                } else if (apiMode === 'userKey' && apiKey) {
                     setApiKeyStatus({ status: 'Đã kết nối', message: 'API Key của bạn đã được tải.', color: 'text-green-500' });
                }
            }}
            className="mt-6 w-full bg-gray-600 hover:bg-gray-500 text-white font-semibold py-2 px-4 rounded-lg shadow-md transition-colors"
          >
            Đóng
        </button>
      </div>
    </div>
  );
};

const GameSetupScreen = ({ 
    goHome, gameSettings, handleInputChange, initializeGame, isLoading, apiKey, 
    setInputApiKey, setShowApiModal, handleFetchSuggestions, isFetchingSuggestions,
    handleGenerateBackstory, isGeneratingContent, apiMode, handleGenerateDifficultyDescription, isGeneratingDifficultyDesc,
    addInitialWorldElement, removeInitialWorldElement, handleInitialElementChange, handleGenerateInitialElementDescription,
    isGeneratingInitialElementDesc, handleGenerateGoal, isGeneratingGoal,
    handleGenerateCharacterName, isGeneratingCharacterName, 
    handleGenerateInitialSkill, isGeneratingInitialSkill
}) => (
    <div className="min-h-screen bg-gray-800 text-white p-4 md:p-6 flex flex-col items-center">
      <div className="w-full max-w-3xl bg-gray-700 p-6 md:p-8 rounded-xl shadow-2xl relative">
        <button onClick={goHome} className="absolute top-4 left-4 text-purple-400 hover:text-purple-300 text-sm flex items-center bg-gray-600 hover:bg-gray-500 p-2 rounded-lg shadow transition-colors">
            <ArrowLeftStartOnRectangleIcon /> Về Trang Chủ
        </button>
        <h2 className="text-3xl md:text-4xl font-bold text-purple-400 mb-8 text-center pt-10 sm:pt-0">Kiến Tạo Thế Giới Của Ngươi</h2>
                
        <div className="grid grid-cols-1 md:grid-cols-2 gap-x-8 gap-y-6 mb-6">
            {/* Column 1: Theme, Setting, Difficulty, NSFW */}
            <div className="space-y-6">
                <fieldset className="border border-gray-600 p-4 rounded-lg">
                    <legend className="text-xl font-semibold text-pink-400 px-2">Bối Cảnh Truyện</legend>
                    <div className="mt-2 space-y-4">
                        <div>
                            <label htmlFor="theme" className="block text-lg font-medium text-gray-300 mb-1">Chủ Đề:</label>
                            <div className="flex items-center gap-2">
                                <input type="text" name="theme" id="theme" value={gameSettings.theme} onChange={handleInputChange} placeholder="VD: Tiên hiệp, Huyền huyễn, Đô thị dị năng..." className="w-full p-3 bg-gray-600 border border-gray-500 rounded-lg focus:ring-pink-500 focus:border-pink-500" />
                                <button onClick={() => handleFetchSuggestions('theme')} disabled={isFetchingSuggestions || (apiMode === 'userKey' && !apiKey)} className="p-3 bg-pink-600 hover:bg-pink-700 rounded-lg disabled:bg-gray-500" title="✨ Gợi ý Chủ đề">
                                    {isFetchingSuggestions ? <div className="w-5 h-5 border-2 border-t-transparent border-white rounded-full animate-spin"></div> : <SparklesIcon className="w-5 h-5 text-white"/>}
                                </button>
                            </div>
                        </div>
                        <div>
                            <label htmlFor="setting" className="block text-lg font-medium text-gray-300 mb-1">Thế Giới/Bối Cảnh Chi Tiết:</label>
                            <div className="flex items-center gap-2">
                                <input type="text" name="setting" id="setting" value={gameSettings.setting} onChange={handleInputChange} placeholder="VD: Đại Lục Phong Vân, Tinh Không Vô Tận..." className="w-full p-3 bg-gray-600 border border-gray-500 rounded-lg focus:ring-pink-500 focus:border-pink-500" />
                                <button onClick={() => handleFetchSuggestions('setting')} disabled={isFetchingSuggestions || (apiMode === 'userKey' && !apiKey)} className="p-3 bg-pink-600 hover:bg-pink-700 rounded-lg disabled:bg-gray-500" title="✨ Gợi ý Bối cảnh">
                                    {isFetchingSuggestions ? <div className="w-5 h-5 border-2 border-t-transparent border-white rounded-full animate-spin"></div> : <SparklesIcon className="w-5 h-5 text-white"/>}
                                </button>
                            </div>
                        </div>
                    </div>
                </fieldset>

                <fieldset className="border border-gray-600 p-4 rounded-lg">
                    <legend className="text-xl font-semibold text-teal-400 px-2">Độ Khó & Nội Dung</legend>
                    <div className="mt-2 space-y-4">
                        <div>
                            <label htmlFor="difficulty" className="block text-lg font-medium text-gray-300 mb-1">Chọn Độ Khó:</label>
                            <select name="difficulty" id="difficulty" value={gameSettings.difficulty} onChange={handleInputChange} className="w-full p-3 bg-gray-600 border border-gray-500 rounded-lg focus:ring-teal-500 focus:border-teal-500">
                                <option value="Dễ">Dễ - Dành cho người mới, ít thử thách</option>
                                <option value="Thường">Thường - Cân bằng, phù hợp đa số</option>
                                <option value="Khó">Khó - Thử thách cao, cần tính toán</option>
                                <option value="Ác Mộng">Ác Mộng - Cực kỳ khó, không khoan nhượng</option>
                                <option value="Tuỳ Chỉnh AI">Tuỳ Chỉnh AI - Để AI mô tả độ khó</option>
                            </select>
                        </div>
                        {(gameSettings.difficulty === "Tuỳ Chỉnh AI" || gameSettings.difficultyDescription) && (
                            <div>
                                <label htmlFor="difficultyDescription" className="block text-lg font-medium text-gray-300 mb-1">Mô Tả Độ Khó (AI hoặc Tự Điền):</label>
                                <div className="flex items-center gap-2">
                                    <textarea name="difficultyDescription" id="difficultyDescription" value={gameSettings.difficultyDescription} onChange={handleInputChange} rows="2" placeholder="AI sẽ mô tả độ khó ở đây..." className="w-full p-3 bg-gray-600 border border-gray-500 rounded-lg focus:ring-teal-500 focus:border-teal-500" />
                                    {gameSettings.difficulty === "Tuỳ Chỉnh AI" && (
                                        <button onClick={handleGenerateDifficultyDescription} disabled={isGeneratingDifficultyDesc || (apiMode === 'userKey' && !apiKey)} className="p-3 bg-teal-600 hover:bg-teal-700 rounded-lg disabled:bg-gray-500 self-start" title="✨ AI Tạo Mô Tả Độ Khó">
                                            {isGeneratingDifficultyDesc ? <div className="w-5 h-5 border-2 border-t-transparent border-white rounded-full animate-spin"></div> : <SparklesIcon className="w-5 h-5 text-white"/>}
                                        </button>
                                    )}
                                </div>
                            </div>
                        )}
                        <div className="flex items-center mt-3">
                            <input type="checkbox" name="allowNsfw" id="allowNsfw" checked={gameSettings.allowNsfw} onChange={handleInputChange} className="h-5 w-5 text-red-500 bg-gray-600 border-gray-500 rounded focus:ring-red-600 focus:ring-offset-gray-800" />
                            <label htmlFor="allowNsfw" className="ml-2 text-sm font-medium text-gray-300">Cho phép nội dung 18+ (Cực kỳ chi tiết)</label>
                        </div>
                         <p className="text-xs text-gray-400 italic">Khi tick chọn, AI sẽ được khuyến khích tạo nội dung khiêu dâm, bạo lực cực đoan một cách trần trụi và chi tiết hơn.</p>
                    </div>
                </fieldset>
            </div>

            {/* Column 2: Character Creation & Goal */}
            <div className="space-y-6">
                 <fieldset className="border border-gray-600 p-4 rounded-lg">
                    <legend className="text-xl font-semibold text-sky-400 px-2">Nhân Vật Chính</legend>
                    <div className="mt-2 space-y-4">
                        <div>
                            <label htmlFor="characterName" className="block text-lg font-medium text-gray-300 mb-1">Danh Xưng/Tên Nhân Vật:</label>
                             <div className="flex items-center gap-2">
                                <input type="text" name="characterName" id="characterName" value={gameSettings.characterName} onChange={handleInputChange} placeholder="VD: Diệp Phàm, Hàn Lập, Lâm Động..." className="w-full p-3 bg-gray-600 border border-gray-500 rounded-lg focus:ring-sky-500 focus:border-sky-500" />
                                <button onClick={handleGenerateCharacterName} disabled={isGeneratingCharacterName || (apiMode === 'userKey' && !apiKey)} className="p-3 bg-sky-600 hover:bg-sky-700 rounded-lg disabled:bg-gray-500" title="✨ Gợi ý Tên Nhân Vật">
                                    {isGeneratingCharacterName ? <div className="w-5 h-5 border-2 border-t-transparent border-white rounded-full animate-spin"></div> : <SparklesIcon className="w-5 h-5 text-white"/>}
                                </button>
                            </div>
                        </div>
                         <div>
                            <label htmlFor="characterPersonality" className="block text-lg font-medium text-gray-300 mb-1">Tính Cách Nhân Vật:</label>
                            <select name="characterPersonality" id="characterPersonality" value={gameSettings.characterPersonality} onChange={handleInputChange} className="w-full p-3 bg-gray-600 border border-gray-500 rounded-lg focus:ring-sky-500 focus:border-sky-500">
                                {PLAYER_PERSONALITIES.map(p => <option key={p} value={p}>{p}</option>)}
                            </select>
                        </div>
                        <div>
                            <label htmlFor="characterGender" className="block text-lg font-medium text-gray-300 mb-1">Giới Tính:</label>
                            <select name="characterGender" id="characterGender" value={gameSettings.characterGender} onChange={handleInputChange} className="w-full p-3 bg-gray-600 border border-gray-500 rounded-lg focus:ring-sky-500 focus:border-sky-500">
                                <option value="Không xác định">Không xác định / Để AI quyết định</option>
                                <option value="Nam">Nam</option>
                                <option value="Nữ">Nữ</option>
                                <option value="Khác">Khác</option>
                            </select>
                        </div>
                        <div>
                            <label htmlFor="characterBackstory" className="block text-lg font-medium text-gray-300 mb-1">Sơ Lược Tiểu Sử/Đặc Điểm (2-3 câu):</label>
                            <div className="flex items-center gap-2">
                                <textarea name="characterBackstory" id="characterBackstory" value={gameSettings.characterBackstory} onChange={handleInputChange} rows="3" placeholder="VD: Một phế vật mang trong mình huyết mạch thượng cổ, một thiếu nữ tài năng bị vị hôn phu từ hôn..." className="w-full p-3 bg-gray-600 border border-gray-500 rounded-lg focus:ring-sky-500 focus:border-sky-500"></textarea>
                                <button onClick={handleGenerateBackstory} disabled={isGeneratingContent || (apiMode === 'userKey' && !apiKey)} className="p-3 bg-sky-600 hover:bg-sky-700 rounded-lg disabled:bg-gray-500 self-start" title="✨ Tạo Tiểu sử">
                                    {isGeneratingContent ? <div className="w-5 h-5 border-2 border-t-transparent border-white rounded-full animate-spin"></div> : <SparklesIcon className="w-5 h-5 text-white"/>}
                                </button>
                            </div>
                        </div>
                        <div>
                            <label htmlFor="preferredInitialSkill" className="block text-lg font-medium text-gray-300 mb-1">Kỹ Năng Khởi Đầu Mong Muốn (Tùy chọn):</label>
                            <div className="flex items-center gap-2">
                                <input type="text" name="preferredInitialSkill" id="preferredInitialSkill" value={gameSettings.preferredInitialSkill} onChange={handleInputChange} placeholder="VD: Thuật ẩn thân, Kiếm pháp cơ bản..." className="w-full p-3 bg-gray-600 border border-gray-500 rounded-lg focus:ring-sky-500 focus:border-sky-500" />
                                <button onClick={handleGenerateInitialSkill} disabled={isGeneratingInitialSkill || (apiMode === 'userKey' && !apiKey)} className="p-3 bg-sky-600 hover:bg-sky-700 rounded-lg disabled:bg-gray-500" title="✨ Gợi ý Kỹ năng">
                                    {isGeneratingInitialSkill ? <div className="w-5 h-5 border-2 border-t-transparent border-white rounded-full animate-spin"></div> : <SparklesIcon className="w-5 h-5 text-white"/>}
                                </button>
                            </div>
                             <p className="text-xs text-gray-400 mt-1 italic">Gợi ý cho AI về loại kỹ năng ngươi muốn bắt đầu. AI sẽ quyết định kỹ năng cụ thể.</p>
                        </div>
                    </div>
                </fieldset>

                <fieldset className="border border-red-500/70 p-4 rounded-lg bg-gray-700/20">
                    <legend className="text-xl font-semibold text-red-400 px-2 flex items-center"><BullseyeIcon /> Mục Tiêu/Động Lực Nhân Vật</legend>
                    <div className="mt-3 space-y-3">
                        <div className="flex items-center">
                            <input 
                                type="checkbox" 
                                name="useCharacterGoal" 
                                id="useCharacterGoal" 
                                checked={gameSettings.useCharacterGoal} 
                                onChange={handleInputChange} 
                                className="h-5 w-5 text-red-500 bg-gray-600 border-gray-500 rounded focus:ring-red-600 focus:ring-offset-gray-800" 
                            />
                            <label htmlFor="useCharacterGoal" className="ml-2 text-sm font-medium text-gray-300">Thêm Mục Tiêu/Động Lực Cho Nhân Vật</label>
                        </div>
                        {gameSettings.useCharacterGoal && (
                            <div>
                                <label htmlFor="characterGoal" className="block text-lg font-medium text-gray-300 mb-1">Mục Tiêu/Động Lực:</label>
                                <div className="flex items-center gap-2">
                                    <textarea 
                                        name="characterGoal" 
                                        id="characterGoal" 
                                        value={gameSettings.characterGoal} 
                                        onChange={handleInputChange} 
                                        rows="3" 
                                        placeholder="VD: Trả thù cho gia tộc, Tìm kiếm chân lý võ đạo, Bảo vệ người yêu, Trở thành kẻ mạnh nhất..." 
                                        className="w-full p-3 bg-gray-600 border border-gray-500 rounded-lg focus:ring-red-500 focus:border-red-500"
                                    />
                                    <button 
                                        onClick={handleGenerateGoal} 
                                        disabled={isGeneratingGoal || (apiMode === 'userKey' && !apiKey)} 
                                        className="p-3 bg-red-600 hover:bg-red-700 rounded-lg disabled:bg-gray-500 self-start" 
                                        title="✨ AI Gợi Ý Mục Tiêu"
                                    >
                                        {isGeneratingGoal ? <div className="w-5 h-5 border-2 border-t-transparent border-white rounded-full animate-spin"></div> : <SparklesIcon className="w-5 h-5 text-white"/>}
                                    </button>
                                </div>
                                <p className="text-xs text-gray-400 mt-1 italic">Mục tiêu này sẽ ảnh hưởng đến suy nghĩ và hành động của nhân vật trong game.</p>
                            </div>
                        )}
                    </div>
                </fieldset>
            </div>
        </div>

        {/* Initial World Elements */}
        <fieldset className="border-2 border-lime-600 p-4 rounded-lg mb-6 bg-gray-700/30">
            <legend className="text-xl font-semibold text-lime-300 px-2 flex items-center">
                <BuildingStorefrontIcon className="text-lime-400"/> Kiến Tạo Thế Giới Ban Đầu (Tùy chọn)
            </legend>
            <div className="mt-3 space-y-4">
                {gameSettings.initialWorldElements.map((element, index) => (
                    <div key={element.id} className="p-3 bg-gray-600/50 rounded-lg border border-gray-500">
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-3 mb-2">
                            <div>
                                <label htmlFor={`elementName-${index}`} className="block text-sm font-medium text-gray-300 mb-1">Tên Thực Thể:</label>
                                <input 
                                    type="text" 
                                    id={`elementName-${index}`}
                                    name="name"
                                    value={element.name} 
                                    onChange={(e) => handleInitialElementChange(index, e)} 
                                    placeholder="VD: Lão Ma Đầu, Hắc Ám Sâm Lâm,..."
                                    className="w-full p-2 bg-gray-500 border border-gray-400 rounded-md focus:ring-lime-500 focus:border-lime-500 text-sm" 
                                />
                            </div>
                            <div>
                                <label htmlFor={`elementType-${index}`} className="block text-sm font-medium text-gray-300 mb-1">Loại Thực Thể:</label>
                                <select 
                                    id={`elementType-${index}`}
                                    name="type"
                                    value={element.type} 
                                    onChange={(e) => handleInitialElementChange(index, e)}
                                    className="w-full p-2 bg-gray-500 border border-gray-400 rounded-md focus:ring-lime-500 focus:border-lime-500 text-sm"
                                >
                                    <option value="NPC">Nhân Vật (NPC)</option>
                                    <option value="LOCATION">Địa Điểm</option>
                                    <option value="ITEM">Vật Phẩm (Lore)</option>
                                </select>
                            </div>
                             <div className="md:col-span-2"> 
                                <label htmlFor={`elementPersonality-${index}`} className="block text-sm font-medium text-gray-300 mb-1">Tính Cách (Nếu là NPC - AI sẽ tự quyết nếu bỏ trống):</label>
                                <input 
                                    type="text" 
                                    id={`elementPersonality-${index}`}
                                    name="personality"
                                    value={element.personality || ''} 
                                    onChange={(e) => handleInitialElementChange(index, e)} 
                                    placeholder="VD: Lạnh lùng, Đa nghi, Hào sảng..."
                                    className="w-full p-2 bg-gray-500 border border-gray-400 rounded-md focus:ring-lime-500 focus:border-lime-500 text-sm" 
                                />
                            </div>
                            <div className="md:col-span-2"> 
                                <label htmlFor={`elementDesc-${index}`} className="block text-sm font-medium text-gray-300 mb-1">Mô Tả Thực Thể:</label>
                                <div className="flex items-start gap-2">
                                    <textarea 
                                        id={`elementDesc-${index}`}
                                        name="description"
                                        value={element.description} 
                                        onChange={(e) => handleInitialElementChange(index, e)} 
                                        rows="2" 
                                        placeholder="Mô tả chi tiết về thực thể này..."
                                        className="w-full p-2 bg-gray-500 border border-gray-400 rounded-md focus:ring-lime-500 focus:border-lime-500 text-sm" 
                                    />
                                    <button 
                                        onClick={() => handleGenerateInitialElementDescription(index)} 
                                        disabled={isGeneratingInitialElementDesc[element.id] || !element.name || (apiMode === 'userKey' && !apiKey)}
                                        className="p-2.5 bg-lime-600 hover:bg-lime-700 rounded-md disabled:bg-gray-500 self-center" 
                                        title="✨ AI Tạo Mô Tả Thực Thể"
                                    >
                                        {isGeneratingInitialElementDesc[element.id] ? <div className="w-4 h-4 border-2 border-t-transparent border-white rounded-full animate-spin"></div> : <SparklesIcon className="w-4 h-4 text-white"/>}
                                    </button>
                                </div>
                            </div>
                        </div>
                        <button 
                            onClick={() => removeInitialWorldElement(element.id)}
                            className="mt-1 text-xs bg-red-700 hover:bg-red-800 text-white py-1 px-2 rounded-md flex items-center"
                        >
                           <TrashIcon className="w-3 h-3 mr-1"/> Xóa Thực Thể Này
                        </button>
                    </div>
                ))}
                <button 
                    onClick={addInitialWorldElement}
                    className="w-full mt-2 py-2 px-4 bg-lime-700 hover:bg-lime-800 text-white font-semibold rounded-lg shadow-md flex items-center justify-center text-sm"
                >
                    <PlusIcon className="mr-1"/> Thêm Thực Thể Ban Đầu
                </button>
            </div>
        </fieldset>

        <button
          onClick={initializeGame}
          disabled={isLoading || (apiMode === 'userKey' && !apiKey)}
          className="w-full mt-6 bg-gradient-to-r from-green-500 to-teal-500 hover:from-green-600 hover:to-teal-600 text-white font-bold py-4 px-6 rounded-xl shadow-lg hover:shadow-xl transition-all transform hover:scale-105 text-xl disabled:from-gray-500 disabled:to-gray-600 disabled:cursor-not-allowed flex items-center justify-center"
        >
          <PlusCircleIcon /> {isLoading ? 'Đang Khởi Tạo Thế Giới...' : ((apiMode === 'userKey' && !apiKey) ? 'Cần API Key Để Bắt Đầu' : 'Khởi Tạo Thế Giới')}
        </button>
         {(apiMode === 'userKey' && !apiKey) && <p className="text-yellow-400 text-sm mt-3 text-center">Vui lòng <button onClick={() => {setInputApiKey(apiKey); setShowApiModal(true);}} className="underline hover:text-yellow-300 font-semibold">thiết lập API Key</button> của ngươi trước khi bắt đầu.</p>}
      </div>
    </div>
  );

const CharacterInfoModal = ({ knowledge, show, onClose, characterPersonality, characterName }) => { 
    if (!show) return null;

    const getStatusIcon = (statusType) => {
        switch (statusType?.toLowerCase()) {
            case 'buff': return <ShieldCheckIcon className="text-green-400 w-4 h-4 inline-block mr-1"/>;
            case 'debuff': return <HeartCrackIcon className="text-red-400 w-4 h-4 inline-block mr-1"/>;
            case 'injury': return <ExclamationTriangleIcon className="text-yellow-500 w-4 h-4 inline-block mr-1"/>;
            default: return <InformationCircleIcon className="text-blue-400 w-4 h-4 inline-block mr-1"/>;
        }
    };

    const getQuestStatusColor = (status) => {
        if (status === 'completed') return 'text-green-400';
        if (status === 'failed') return 'text-red-400';
        return 'text-yellow-400'; // active
    };

    const renderSection = (title, items, icon = null, itemColor = "text-green-300", renderItem, emptyText = "Chưa có thông tin.") => {
        if (!items || items.length === 0) return (
            <div className="mb-4">
                <h4 className={`text-lg font-semibold ${itemColor} mb-1 flex items-center`}>{icon && <span className="mr-1.5">{icon}</span>}{title}</h4>
                <p className="text-gray-400 italic text-sm pl-2">{emptyText}</p>
            </div>
        );
        return (
            <div className="mb-4">
                <h4 className={`text-lg font-semibold ${itemColor} mb-2 flex items-center`}>{icon && <span className="mr-1.5">{icon}</span>}{title}</h4>
                <ul className="list-disc list-inside space-y-1 pl-2 text-sm">
                    {items.map((item, index) => renderItem(item, index, itemColor))}
                </ul>
            </div>
        );
    };

    return (
        <div className="fixed inset-0 bg-black bg-opacity-75 flex items-center justify-center p-4 z-50">
            <div className="bg-gray-800 p-6 rounded-xl shadow-2xl w-full max-w-xl max-h-[85vh] flex flex-col border border-purple-600">
                <h3 className="text-2xl font-bold text-purple-400 mb-4 flex items-center"><CharacterSheetIcon /> Thông Tin Nhân Vật & Thế Giới</h3>
                <div className="overflow-y-auto flex-grow pr-2 scrollbar-thin scrollbar-thumb-purple-500 scrollbar-track-gray-700">
                    <div className="mb-4">
                        <h4 className="text-lg font-semibold text-amber-400 mb-1 flex items-center"><UserCircleIcon /> Nhân Vật Chính</h4>
                        {characterName && <p className="text-gray-300 text-sm pl-2">Tên: {characterName}</p>}
                        <p className="text-gray-300 text-sm pl-2">Tính cách: {characterPersonality || "Chưa xác định"}</p>
                    </div>
                    
                    {renderSection("Trạng Thái Hiện Tại", knowledge.playerStatus, <InformationCircleIcon className="text-indigo-400"/>, "text-indigo-400", (item, index, color) => (
                        <li key={`status-${index}`} className="text-gray-300 p-1.5 bg-gray-700/50 rounded-md">
                            <strong className={color}>{getStatusIcon(item.type)} {item.name || "Trạng thái không tên"}</strong>: {item.description || "Không có mô tả."}
                            <div className="text-xs text-gray-400 ml-3">
                                {item.type && <span>Loại: {item.type}. </span>}
                                {item.duration && <span>Thời gian: {item.duration}. </span>}
                                {item.effects && <span>Ảnh hưởng: {item.effects}. </span>}
                                {item.cureConditions && <span>Điều kiện hóa giải: {item.cureConditions}. </span>}
                                {item.source && <span>Nguồn: {item.source}.</span>}
                            </div>
                        </li>
                    ), "Không có trạng thái nào đang hoạt động.")}
                    
                    {renderSection("Nhật Ký Nhiệm Vụ", knowledge.quests, <ClipboardDocumentCheckIcon className="text-yellow-400"/>, "text-yellow-400", (quest, index) => (
                        <li key={`quest-${index}`} className={`text-gray-200 p-2 bg-gray-700/60 rounded-md border-l-4 ${quest.status === 'completed' ? 'border-green-500' : quest.status === 'failed' ? 'border-red-500' : 'border-yellow-500'}`}>
                            <div className="flex justify-between items-start">
                                <strong className={`font-semibold ${getQuestStatusColor(quest.status)}`}>{quest.title || "Nhiệm vụ không tên"}</strong>
                                <span className={`text-xs px-1.5 py-0.5 rounded-full ${
                                    quest.status === 'completed' ? 'bg-green-600 text-green-100' :
                                    quest.status === 'failed' ? 'bg-red-600 text-red-100' :
                                    'bg-yellow-600 text-yellow-100'
                                }`}>
                                    {quest.status === 'active' ? 'Đang làm' : quest.status === 'completed' ? 'Hoàn thành' : 'Thất bại'}
                                </span>
                            </div>
                            <p className="text-xs text-gray-300 mt-1">{quest.description || "Không có mô tả."}</p>
                            {quest.objectives && quest.objectives.length > 0 && (
                                <ul className="list-disc list-inside text-xs text-gray-400 mt-1 pl-3">
                                    {quest.objectives.map((obj, oIdx) => (
                                        <li key={oIdx} className={obj.completed ? 'line-through text-gray-500' : ''}>
                                            {obj.text}
                                        </li>
                                    ))}
                                </ul>
                            )}
                            {quest.giver && <p className="text-xs text-gray-400 mt-1">Người giao: {quest.giver}</p>}
                            {quest.reward && <p className="text-xs text-gray-400 mt-1">Phần thưởng: {quest.reward}</p>}
                        </li>
                    ), "Chưa nhận nhiệm vụ nào.")}


                    {renderSection("Balo Đồ", knowledge.inventory, <BackpackIcon className="text-orange-400"/>, "text-orange-400", (item, index, color) => (
                        <li key={`inventory-${index}`} className="text-gray-300">
                            <strong className={color}>{item.Name || "Vật phẩm không tên"}</strong>: {item.Description || "Không có mô tả."}
                            <span className="text-xs text-gray-400 ml-1">
                                ({item.Type || "Chưa rõ loại"})
                                {item.Equippable ? " (Có thể trang bị)" : ""}
                                {item.Usable ? " (Có thể sử dụng)" : ""}
                                {item.Consumable ? " (Tiêu hao)" : ""}
                                {typeof item.Uses === 'number' ? ` (Còn ${item.Uses} lần)` : ""}
                            </span>
                        </li>
                    ))}
                    {renderSection("Kỹ Năng", knowledge.playerSkills, <BoltIcon className="text-yellow-400"/>, "text-yellow-400", (item, index, color) => (
                         <li key={`skill-${index}`} className="text-gray-300">
                            <strong className={color}>{item.Name || "Kỹ năng không tên"}</strong>: {item.Description || "Không có mô tả."}
                            {item.Type && <span className="text-xs text-gray-400 ml-1">({item.Type})</span>}
                        </li>
                    ))}
                     {renderSection("Mối Quan Hệ", knowledge.relationships, <HeartIcon className="text-pink-400"/>, "text-pink-400", (item, index, color) => (
                        <li key={`relation-${index}`} className="text-gray-300">
                            <strong className={color}>{item.NPC || "NPC không tên"}</strong>: {item.Standing || "Chưa rõ"}
                            {item.Reason && <span className="text-xs text-gray-400 italic ml-1">- {item.Reason}</span>}
                        </li>
                    ))}
                    {renderSection("Nhân Vật Đã Gặp (NPCs)", knowledge.npcs, <UserCircleIcon />, "text-sky-400", (item, index, color) => (
                        <li key={`npc-${index}`} className="text-gray-300">
                            <strong className={color}>{item.Name || "Không rõ tên"}</strong>
                            {item.Personality && <span className="text-gray-400 text-xs"> (Tính cách: {item.Personality})</span>}: {item.Description || "Chưa có mô tả."}
                            {item.statuses && item.statuses.length > 0 && (
                                <div className="text-xs text-gray-400 ml-3 mt-0.5">
                                    Trạng thái NPC: {item.statuses.map(s => `${s.name} (${s.type})`).join(', ')}
                                </div>
                            )}
                        </li>
                    ))}
                    {renderSection("Vật Phẩm Thế Giới (Lore)", knowledge.items, <SparklesIcon className="w-5 h-5 text-yellow-400"/>, "text-yellow-400", (item, index, color) => (
                         <li key={`loreitem-${index}`} className="text-gray-300">
                            <strong className={color}>{item.Name || "Không rõ tên"}:</strong> {item.Description || "Chưa có mô tả."}
                        </li>
                    ))}
                    {renderSection("Địa Điểm Đã Khám Phá", knowledge.locations, <InformationCircleIcon className="w-5 h-5 text-blue-400"/>, "text-blue-400", (item, index, color) => (
                         <li key={`location-${index}`} className="text-gray-300">
                            <strong className={color}>{item.Name || "Không rõ tên"}:</strong> {item.Description || "Chưa có mô tả."}
                        </li>
                    ))}
                    {renderSection("Đồng Hành", knowledge.companions, <UserGroupIcon className="text-lime-400"/>, "text-lime-400", (item, index, color) => (
                        <li key={`companion-${index}`} className="text-gray-300">
                            <strong className={color}>{item.Name || "Không rõ tên"}</strong>
                             {item.Personality && <span className="text-gray-400 text-xs"> (Tính cách: {item.Personality})</span>}: {item.Description || "Chưa có mô tả."}
                            {item.Stats && <span className="text-xs text-gray-400 ml-2">({item.Stats})</span>}
                             {item.statuses && item.statuses.length > 0 && (
                                <div className="text-xs text-gray-400 ml-3 mt-0.5">
                                    Trạng thái Đồng Hành: {item.statuses.map(s => `${s.name} (${s.type})`).join(', ')}
                                </div>
                            )}
                        </li>
                    ))}
                </div>
                <button
                    onClick={onClose}
                    className="mt-6 w-full bg-purple-600 hover:bg-purple-700 text-white font-semibold py-2 px-4 rounded-lg"
                >
                    Đóng
                </button>
            </div>
        </div>
    );
};

const QuickLoreModal = ({ loreItem, show, onClose }) => {
    if (!show || !loreItem) return null;
    let icon = <InformationCircleIcon className="w-5 h-5 mr-2 text-cyan-400 mt-1"/>;
    const category = loreItem.category?.toLowerCase();

    if (category === 'npcs') icon = <UserCircleIcon />;
    else if (category === 'items' || category === 'inventory') icon = <SparklesIcon className="w-5 h-5 mr-2 text-yellow-400 mt-1"/>;
    else if (category === 'companions') icon = <UserGroupIcon className="w-5 h-5 mr-2 text-lime-400 mt-1"/>;
    else if (category === 'playerskills') icon = <BoltIcon className="w-5 h-5 mr-2 text-yellow-400 mt-1"/>;
    else if (category === 'relationships') icon = <HeartIcon className="w-5 h-5 mr-2 text-pink-400 mt-1"/>;
    else if (category === 'quests') icon = <ClipboardDocumentCheckIcon className="w-5 h-5 mr-2 text-yellow-400 mt-1"/>;
    else if (category === 'playerstatus') {
        switch (loreItem.type?.toLowerCase()) {
            case 'buff': icon = <ShieldCheckIcon className="text-green-400 w-5 h-5 mr-2 mt-1"/>; break;
            case 'debuff': icon = <HeartCrackIcon className="text-red-400 w-5 h-5 mr-2 mt-1"/>; break;
            case 'injury': icon = <ExclamationTriangleIcon className="text-yellow-500 w-5 h-5 mr-2 mt-1"/>; break;
            default: icon = <InformationCircleIcon className="text-blue-400 w-5 h-5 mr-2 mt-1"/>; break;
        }
    }


    return (
        <div className="fixed inset-0 bg-black bg-opacity-60 flex items-center justify-center p-4 z-[80]" onClick={onClose}>
            <div className="bg-gray-700 p-5 rounded-lg shadow-xl w-full max-w-sm border border-cyan-700" onClick={(e) => e.stopPropagation()}>
                <div className="flex items-start mb-2">
                    {icon}
                    <h4 className="text-lg font-semibold text-cyan-300">{loreItem.Name || loreItem.NPC || loreItem.name || loreItem.title || "Không rõ tên"}</h4>
                </div>
                <p className="text-sm text-gray-200 bg-gray-600 p-3 rounded max-h-40 overflow-y-auto whitespace-pre-line scrollbar-thin scrollbar-thumb-gray-500 scrollbar-track-gray-600">
                    {loreItem.Description || loreItem.Standing || loreItem.description || "Không có mô tả chi tiết."}
                </p>
                {loreItem.Personality && <p className="text-xs text-gray-300 mt-1"><strong>Tính cách:</strong> {loreItem.Personality}</p>}
                {loreItem.Stats && <p className="text-xs text-gray-300 mt-1"><strong>Chỉ số:</strong> {loreItem.Stats}</p>}
                {loreItem.Type && !loreItem.type && <p className="text-xs text-gray-300 mt-1"><strong>Loại (Lore):</strong> {loreItem.Type}</p>}
                {loreItem.type && <p className="text-xs text-gray-300 mt-1"><strong>Loại (Trạng thái):</strong> {loreItem.type}</p>}
                {loreItem.duration && <p className="text-xs text-gray-300 mt-1"><strong>Thời gian:</strong> {loreItem.duration}</p>}
                {loreItem.effects && <p className="text-xs text-gray-300 mt-1"><strong>Ảnh hưởng:</strong> {loreItem.effects}</p>}
                {loreItem.cureConditions && <p className="text-xs text-gray-300 mt-1"><strong>Điều kiện hóa giải:</strong> {loreItem.cureConditions}</p>}
                {loreItem.source && <p className="text-xs text-gray-300 mt-1"><strong>Nguồn:</strong> {loreItem.source}</p>}
                {loreItem.Reason && <p className="text-xs text-gray-300 mt-1"><strong>Lý do (Quan hệ):</strong> {loreItem.Reason}</p>}
                {loreItem.Equippable !== undefined && <p className="text-xs text-gray-300 mt-1"><strong>Có thể trang bị:</strong> {loreItem.Equippable ? "Có" : "Không"}</p>}
                {loreItem.Usable !== undefined && <p className="text-xs text-gray-300 mt-1"><strong>Có thể sử dụng:</strong> {loreItem.Usable ? "Có" : "Không"}</p>}
                {loreItem.Consumable !== undefined && <p className="text-xs text-gray-300 mt-1"><strong>Tiêu hao khi dùng:</strong> {loreItem.Consumable ? "Có" : "Không"}</p>}
                {typeof loreItem.Uses === 'number' && <p className="text-xs text-gray-300 mt-1"><strong>Số lần dùng còn lại:</strong> {loreItem.Uses}</p>}
                {/* Quest specific details */}
                {category === 'quests' && (
                    <>
                        {loreItem.status && <p className="text-xs text-gray-300 mt-1"><strong>Trạng thái NV:</strong> {loreItem.status === 'active' ? 'Đang làm' : loreItem.status === 'completed' ? 'Hoàn thành' : 'Thất bại'}</p>}
                        {loreItem.objectives && loreItem.objectives.length > 0 && (
                            <div className="mt-1">
                                <p className="text-xs text-gray-300 font-semibold">Mục tiêu:</p>
                                <ul className="list-disc list-inside text-xs text-gray-400 pl-3">
                                    {loreItem.objectives.map((obj, idx) => (
                                        <li key={idx} className={obj.completed ? 'line-through text-gray-500' : ''}>{obj.text}</li>
                                    ))}
                                </ul>
                            </div>
                        )}
                        {loreItem.giver && <p className="text-xs text-gray-300 mt-1"><strong>Người giao:</strong> {loreItem.giver}</p>}
                        {loreItem.reward && <p className="text-xs text-gray-300 mt-1"><strong>Phần thưởng:</strong> {loreItem.reward}</p>}
                    </>
                )}
                 <button
                    onClick={onClose}
                    className="mt-4 w-full bg-purple-600 hover:bg-purple-700 text-white font-semibold py-2 px-3 rounded-md text-sm"
                >
                    Đóng
                </button>
            </div>
        </div>
    );
};

const SuggestedActionsModal = ({ show, suggestions, onSelect, onClose, isLoading }) => {
    if (!show) return null;
    return (
        <div className="fixed inset-0 bg-black bg-opacity-75 flex items-center justify-center p-4 z-[90]">
            <div className="bg-gray-700 p-6 rounded-xl shadow-2xl w-full max-w-md border border-purple-700">
                <h3 className="text-xl font-semibold text-purple-400 mb-4 flex items-center">
                    <LightBulbIcon className="text-purple-400"/> Gợi Ý Hành Động
                </h3>
                {isLoading ? (
                    <div className="flex justify-center items-center h-24">
                        <div className="w-8 h-8 border-4 border-t-transparent border-purple-400 rounded-full animate-spin"></div>
                        <p className="ml-3 text-gray-300">AI đang nghĩ gợi ý...</p>
                    </div>
                ) : suggestions.length > 0 ? (
                    <ul className="space-y-2 max-h-60 overflow-y-auto scrollbar-thin scrollbar-thumb-purple-500 scrollbar-track-gray-700">
                        {suggestions.map((suggestion, index) => (
                            <li key={index}>
                                <button
                                    onClick={() => { onSelect(suggestion); onClose(); }}
                                    className="w-full text-left p-3 bg-gray-600 hover:bg-gray-500/80 rounded-md text-gray-200 transition-colors shadow hover:shadow-md"
                                >
                                    {suggestion}
                                </button>
                            </li>
                        ))}
                    </ul>
                ) : (
                    <p className="text-gray-400 text-center py-4">Không có gợi ý nào được tạo ra lúc này.</p>
                )}
                <button
                    onClick={onClose}
                    className="mt-6 w-full bg-gray-500 hover:bg-gray-400 text-white font-semibold py-2 px-4 rounded-lg"
                >
                    Đóng
                </button>
            </div>
        </div>
    );
};


const GameplayScreen = ({ 
    goHome, gameSettings, restartGame, storyHistory, isLoading, currentStory, 
    choices, handleChoice, formatStoryText, customActionInput, setCustomActionInput, 
    handleCustomAction, knowledgeBase, setShowCharacterInfoModal, 
    isProcessingAction, handleGenerateSuggestedActions, isGeneratingSuggestedActions
}) => (
    <div className="min-h-screen bg-gray-900 text-gray-100 flex flex-col p-2 md:p-4 font-['Arial',_sans-serif]">
        <header className="flex flex-col sm:flex-row justify-between items-center mb-3 gap-2 p-2 bg-gray-800/50 rounded-lg shadow-md">
            <button onClick={goHome} className="bg-purple-600 hover:bg-purple-700 text-white font-semibold py-2 px-3 rounded-lg shadow-md transition-colors flex items-center self-start sm:self-center text-sm">
                <ArrowLeftStartOnRectangleIcon /> Về Trang Chủ
            </button>
            <div className="text-center flex-1 mx-2 order-first sm:order-none max-w-md sm:max-w-full"> 
                <h1 className="text-lg md:text-xl font-bold text-purple-300" title={gameSettings.theme || "Cuộc Phiêu Lưu"}>
                    {gameSettings.theme || "Cuộc Phiêu Lưu"}
                </h1>
                 {gameSettings.characterPersonality && (
                    <p className="text-xs text-sky-300 flex items-center justify-center mt-0.5" title={`Tính cách: ${gameSettings.characterPersonality}`}>
                        <FaceSmileIcon className="w-4 h-4 mr-1 text-sky-400 flex-shrink-0"/> 
                        <span className="leading-tight">Tính cách: {gameSettings.characterPersonality}</span>
                    </p>
                )}
                {gameSettings.useCharacterGoal && gameSettings.characterGoal && (
                     <div className="text-xs text-red-300 flex items-start justify-center text-center mt-0.5" title={`Mục tiêu: ${gameSettings.characterGoal}`}>
                        <BullseyeIcon className="w-4 h-4 mr-1 text-red-400 flex-shrink-0 mt-px"/>
                        <span className="ml-1 leading-tight">Mục tiêu: {gameSettings.characterGoal}</span>
                    </div>
                )}
            </div>
            <div className="flex gap-1.5 self-end sm:self-center flex-wrap justify-end">
                <button onClick={() => setShowCharacterInfoModal(true)} disabled={isLoading || isProcessingAction} className="bg-teal-600 hover:bg-teal-700 text-white font-semibold py-2 px-2.5 rounded-lg shadow-md transition-colors flex items-center text-xs disabled:bg-gray-500">
                    <CharacterSheetIcon /> Thông Tin
                </button>
                <button onClick={restartGame} disabled={isLoading || isProcessingAction} className="bg-red-600 hover:bg-red-700 text-white font-semibold py-2 px-2.5 rounded-lg shadow-md transition-colors flex items-center text-xs disabled:bg-gray-500">
                    <ArrowPathIcon className="w-4 h-4 mr-1"/> Bắt Đầu Lại
                </button>
            </div>
        </header>
        
        {knowledgeBase.playerStatus && knowledgeBase.playerStatus.length > 0 && (
            <div className="bg-gray-750 p-3 rounded-xl shadow-lg mb-3 border border-indigo-700/50">
                <h4 className="text-md font-semibold text-indigo-400 mb-1.5 flex items-center">
                    <InformationCircleIcon className="text-indigo-400 w-5 h-5 mr-1.5"/> Trạng Thái Hiện Tại
                </h4>
                <div className="flex flex-wrap gap-2 text-xs">
                    {knowledgeBase.playerStatus.map((status, index) => {
                         let icon;
                         let textColor = "text-gray-300";
                         switch (status.type?.toLowerCase()) {
                             case 'buff': icon = <ShieldCheckIcon className="text-green-400"/>; textColor = "text-green-300"; break;
                             case 'debuff': icon = <HeartCrackIcon className="text-red-400"/>; textColor = "text-red-300"; break;
                             case 'injury': icon = <ExclamationTriangleIcon className="text-yellow-500"/>; textColor = "text-yellow-300"; break;
                             default: icon = <InformationCircleIcon className="text-blue-400"/>; textColor = "text-blue-300"; break;
                         }
                         return (
                            <div key={index} className={`flex items-center bg-gray-700 p-1.5 rounded-md shadow ${textColor}`} title={`${status.description} (Ảnh hưởng: ${status.effects || 'Không rõ'}) (Nguồn: ${status.source || 'Không rõ'}) (Thời gian: ${status.duration || 'Không rõ'})`}>
                                {React.cloneElement(icon, { className: "w-4 h-4 mr-1" })}
                                {status.name}
                            </div>
                         );
                    })}
                </div>
            </div>
        )}

        {/* Active Quests Quick View */}
        {knowledgeBase.quests && knowledgeBase.quests.filter(q => q.status === 'active').length > 0 && (
    <div className="bg-gray-750 p-3 rounded-xl shadow-lg mb-3 border border-yellow-600/50">
        <h4 className="text-md font-semibold text-yellow-400 mb-1.5 flex items-center">
            {/* Thay đổi ở dòng dưới: thêm w-5 h-5 và mr-1.5 */}
            <ClipboardDocumentCheckIcon className="w-5 h-5 mr-1.5 text-yellow-400"/> 
            Nhiệm Vụ Đang Làm
        </h4>
        <div className="flex flex-wrap gap-2 text-xs">
            {knowledgeBase.quests.filter(q => q.status === 'active').map((quest, index) => (
                <div 
                    key={index} 
                    className="flex items-center bg-yellow-700/30 hover:bg-yellow-700/50 p-1.5 rounded-md shadow text-yellow-200 cursor-pointer" 
                    title={`${quest.description}\nMục tiêu: ${quest.objectives && quest.objectives.length > 0 ? quest.objectives.map(obj => `${obj.text} (${obj.completed ? 'Xong' : 'Chưa'})`).join(', ') : 'Không có'}`}
                    onClick={() => setShowCharacterInfoModal(true)} // Open full info modal
                >
                    <ClipboardDocumentCheckIcon className="w-4 h-4 mr-1 text-yellow-300"/> {quest.title}
                </div>
            ))}
        </div>
    </div>
)}


        {knowledgeBase.companions && knowledgeBase.companions.length > 0 && (
            <div className="bg-gray-750 p-3 rounded-xl shadow-lg mb-4 border border-lime-700/50">
                <h4 className="text-md font-semibold text-lime-400 mb-2 flex items-center"><UserGroupIcon className="text-lime-400"/> Đồng Hành</h4>
                <ul className="space-y-1 text-sm">
                    {knowledgeBase.companions.map((companion, index) => (
                        <li key={index} className="text-gray-300 bg-gray-700 p-2 rounded-md">
                            <strong className="text-lime-300">{companion.Name}</strong>
                            {companion.Personality && <span className="text-gray-400 text-xs"> (Tính cách: {companion.Personality})</span>}: {companion.Description}
                            {companion.Stats && <span className="text-xs text-gray-400 ml-2">({companion.Stats})</span>}
                            {companion.statuses && companion.statuses.length > 0 && (
                                <div className="text-xs text-gray-400 ml-3 mt-0.5">
                                    Trạng thái: {companion.statuses.map(s => `${s.name} (${s.type})`).join(', ')}
                                </div>
                            )}
                        </li>
                    ))}
                </ul>
            </div>
        )}


        <div className="flex-grow bg-gray-800 p-3 md:p-5 rounded-xl shadow-2xl overflow-y-auto mb-3 scrollbar-thin scrollbar-thumb-purple-600 scrollbar-track-gray-700" style={{ maxHeight: '60vh', minHeight: '300px' }} id="story-content-area"> 
            <h2 className="text-lg font-semibold text-green-400 mb-2">Diễn biến câu chuyện:</h2>
            {storyHistory.map((item, index) => (
                <div key={index} className={`story-item mb-3 p-3 rounded-lg shadow-sm
                    ${item.type === 'story' ? 'bg-gray-700/80' : 
                      item.type === 'user_choice' ? 'bg-blue-900/70 text-blue-200 ring-1 ring-blue-700' : 
                      item.type === 'user_custom_action' ? 'bg-indigo-900/70 text-indigo-200 ring-1 ring-indigo-700' : 
                      'bg-yellow-800/70 text-yellow-200 ring-1 ring-yellow-700'}`}>
                    {item.type === 'user_choice' && <p className="font-semibold text-blue-300">Ngươi đã chọn:</p>}
                    {item.type === 'user_custom_action' && <p className="font-semibold text-indigo-300">Hành động của ngươi:</p>}
                    {item.type === 'system' && <p className="font-semibold text-yellow-300">Thông báo hệ thống:</p>}
                    <div className="prose prose-sm prose-invert max-w-none text-gray-200">{formatStoryText(item.content)}</div>
                </div>
            ))}
            {(isLoading || isProcessingAction) && currentStory === '' && (
                <div className="text-center py-10">
                    <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-purple-400 mx-auto"></div>
                    <p className="mt-3 text-purple-300">AI đang viết tiếp câu chuyện...</p>
                </div>
            )}
        </div>

        {!(isLoading || isProcessingAction) && (
            <div className="bg-gray-800 p-3 md:p-5 rounded-xl shadow-xl mt-auto">
                {choices.length > 0 && (
                    <>
                        <h3 className="text-lg font-semibold text-green-400 mb-3">Lựa chọn của ngươi:</h3>
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-3 mb-4">
                            {choices.map((choice, index) => (
                                <button
                                    key={index}
                                    onClick={() => handleChoice(choice)}
                                    className="w-full bg-indigo-600 hover:bg-indigo-700 text-white font-medium py-3 px-4 rounded-lg shadow-md hover:shadow-lg transition-all text-left focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-opacity-75"
                                >
                                    {index + 1}. {choice}
                                </button>
                            ))}
                        </div>
                    </>
                )}
                {gameSettings.allowCustomActionInput && ( 
                    <div>
                        <label htmlFor="customActionInput" className="block text-md font-medium text-gray-300 mb-1">Hoặc nhập hành động tùy ý:</label>
                        <div className="flex gap-2">
                            <input
                                type="text"
                                id="customActionInput"
                                value={customActionInput}
                                onChange={(e) => setCustomActionInput(e.target.value)}
                                placeholder="Ví dụ: Nhìn xung quanh, Hỏi về chiếc chìa khóa..."
                                className="flex-grow p-3 bg-gray-700 border border-gray-600 rounded-lg text-white focus:ring-purple-500 focus:border-purple-500"
                                onKeyPress={(e) => e.key === 'Enter' && handleCustomAction(customActionInput)}
                            />
                             <button
                                onClick={() => handleCustomAction(customActionInput)}
                                disabled={isLoading || isProcessingAction}
                                className="bg-purple-600 hover:bg-purple-700 text-white font-semibold py-3 px-5 rounded-lg shadow-md hover:shadow-lg transition-colors disabled:bg-gray-500"
                            >
                                Gửi
                            </button>
                        </div>
                    </div>
                )}
                 <button 
                    onClick={handleGenerateSuggestedActions} 
                    disabled={isGeneratingSuggestedActions || isLoading || isProcessingAction}
                    className="mt-3 w-full sm:w-auto p-3 bg-teal-600 hover:bg-teal-700 text-white rounded-lg shadow-md disabled:bg-gray-500 flex items-center justify-center" 
                    title="AI Gợi Ý Hành Động"
                >
                    {isGeneratingSuggestedActions ? <div className="w-5 h-5 border-2 border-t-transparent border-white rounded-full animate-spin mr-2"></div> : <SparklesIcon className="w-5 h-5 mr-2"/>}
                    AI Gợi Ý Hành Động
                </button>
            </div>
        )}
         {(isLoading || isProcessingAction) && choices.length === 0 && currentStory !== '' && ( 
            <div className="text-center py-5">
                <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-purple-400 mx-auto"></div>
                <p className="mt-2 text-purple-300">Đang tạo lựa chọn...</p>
            </div>
        )}
    </div>
);


const LoadGameModal = ({ savedGames, loadGame, setShowLoadGameModal, setConfirmationModal, userId, setModalMessage }) => (
    <div className="fixed inset-0 bg-black bg-opacity-75 flex items-center justify-center p-4 z-50">
      <div className="bg-gray-800 p-6 rounded-xl shadow-2xl w-full max-w-2xl max-h-[85vh] flex flex-col border border-blue-600">
        <h2 className="text-2xl font-semibold text-purple-400 mb-4">Tải Game Đã Lưu</h2>
        {savedGames.length === 0 ? (
          <p className="text-gray-400 text-center py-6">Ngươi chưa có cuộc phiêu lưu nào được lưu lại.</p>
        ) : (
          <div className="overflow-y-auto space-y-3 pr-2 scrollbar-thin scrollbar-thumb-blue-500 scrollbar-track-gray-700">
            {savedGames.map(game => (
              <div key={game.id} className="bg-gray-700 p-4 rounded-lg hover:bg-gray-600/80 transition-colors shadow-md hover:shadow-lg">
                <h3 className="text-lg font-semibold text-green-400 truncate" title={game.settings?.theme}>{game.settings?.theme || "Game Chưa Có Tên"}</h3>
                <p className="text-sm text-gray-300">Nhân vật: {game.settings?.characterName || "N/A"} (Tính cách: {game.settings?.characterPersonality || "Chưa rõ"})</p>
                {game.settings?.useCharacterGoal && game.settings?.characterGoal && (
                    <p className="text-xs text-red-300 truncate" title={`Mục tiêu: ${game.settings.characterGoal}`}>
                        Mục tiêu: {game.settings.characterGoal.substring(0,70)}{game.settings.characterGoal.length > 70 ? "..." : ""}
                    </p>
                )}
                <p className="text-xs text-gray-400">
                  Lần cập nhật cuối: {game.updatedAt ? new Date(game.updatedAt.toDate()).toLocaleString('vi-VN') : "N/A"}
                </p>
                 <p className="text-xs text-gray-400">Độ khó: {game.settings?.difficulty || "Không rõ"} {game.settings?.difficultyDescription ? `(${game.settings.difficultyDescription.substring(0,30)}...)` : ""}</p>
                <div className="mt-3 flex space-x-2">
                    <button
                    onClick={() => loadGame(game)}
                    className="flex-1 bg-blue-600 hover:bg-blue-700 text-white font-semibold py-2 px-3 rounded-md text-sm shadow hover:shadow-md transition-all"
                    >
                    Tải Game Này
                    </button>
                    <button
                    onClick={() => {
                        setConfirmationModal({
                            show: true,
                            title: 'Xác Nhận Xóa Game',
                            content: `Bạn có chắc chắn muốn xóa game "${game.settings?.theme || game.id}" không? Hành động này không thể hoàn tác.`,
                            onConfirm: async () => {
                                try {
                                    await deleteDoc(doc(db, `artifacts/${appId}/users/${userId}/games`, game.id));
                                    console.log("Game deleted:", game.id);
                                    setModalMessage({ show: true, title: 'Đã Xóa', content: `Game "${game.settings?.theme || game.id}" đã được xóa.`, type: 'success' });
                                } catch (error) {
                                    console.error("Error deleting game:", error);
                                    setModalMessage({ show: true, title: 'Lỗi Xóa Game', content: `Không thể xóa game: ${error.message}`, type: 'error' });
                                }
                            },
                            confirmText: "Xóa Game",
                            cancelText: "Hủy Bỏ"
                        });
                    }}
                    className="bg-red-600 hover:bg-red-700 text-white font-semibold py-2 px-3 rounded-md text-sm shadow hover:shadow-md transition-all"
                    >
                    Xóa
                    </button>
                </div>
              </div>
            ))}
          </div>
        )}
        <button
          onClick={() => setShowLoadGameModal(false)}
          className="mt-6 w-full bg-gray-600 hover:bg-gray-500 text-white font-semibold py-2 px-4 rounded-lg shadow-md transition-colors"
        >
          Đóng
        </button>
      </div>
    </div>
  );

const MessageModal = ({ show, title, content, type, onClose }) => {
    if (!show) return null;
    let titleColor = 'text-blue-400';
    let IconComponent = InformationCircleIcon;
    if (type === 'error') {
        titleColor = 'text-red-400';
        IconComponent = () => <ExclamationTriangleIcon className="w-6 h-6 mr-2 text-red-400"/>;
    } else if (type === 'success') {
        titleColor = 'text-green-400';
        IconComponent = CheckIcon;
    }

    return (
      <div className="fixed inset-0 bg-black bg-opacity-75 flex items-center justify-center p-4 z-[100]"> 
        <div className="bg-gray-800 p-6 rounded-xl shadow-2xl w-full max-w-md border border-gray-700">
          <div className="flex items-center mb-4">
            <IconComponent />
            <h3 className={`text-xl font-semibold ${titleColor}`}>{title}</h3>
          </div>
          <p className="text-gray-300 mb-6 whitespace-pre-line">{content}</p>
          <button
            onClick={onClose}
            className="w-full bg-purple-600 hover:bg-purple-700 text-white font-semibold py-2.5 px-4 rounded-lg shadow hover:shadow-md transition-all"
          >
            Đã hiểu
          </button>
        </div>
      </div>
    );
  };

const ConfirmationModal = ({ show, title, content, onConfirm, onCancel, confirmText = "Xác nhận", cancelText = "Hủy", setConfirmationModal: localSetConfirmationModal }) => {
    if (!show) return null;
    return (
      <div className="fixed inset-0 bg-black bg-opacity-75 flex items-center justify-center p-4 z-[100]"> 
        <div className="bg-gray-800 p-6 rounded-xl shadow-2xl w-full max-w-md border border-yellow-700">
          <div className="flex items-center mb-4">
            <ExclamationTriangleIcon /> 
            <h3 className="text-xl font-semibold text-yellow-400">{title}</h3>
          </div>
          <p className="text-gray-300 mb-6 whitespace-pre-line">{content}</p>
          <div className="flex flex-col sm:flex-row space-y-2 sm:space-y-0 sm:space-x-3">
            <button
              onClick={() => { onConfirm(); localSetConfirmationModal(prev => ({ ...prev, show: false })); }}
              className={`flex-1 text-white font-semibold py-2.5 px-4 rounded-lg shadow hover:shadow-md transition-all ${confirmText.toLowerCase().includes("xóa") || confirmText.toLowerCase().includes("delete") ? 'bg-red-600 hover:bg-red-700' : 'bg-green-600 hover:bg-green-700'}`}
            >
              {confirmText}
            </button>
            <button
              onClick={() => { if (onCancel) onCancel(); localSetConfirmationModal(prev => ({ ...prev, show: false })); }}
              className="flex-1 bg-gray-600 hover:bg-gray-500 text-white font-semibold py-2.5 px-4 rounded-lg shadow hover:shadow-md transition-all"
            >
              {cancelText}
            </button>
          </div>
        </div>
      </div>
    );
  };

const SuggestionsModal = ({ show, title, suggestions, onSelect, onClose, isLoading }) => {
    if (!show) return null;
    return (
        <div className="fixed inset-0 bg-black bg-opacity-75 flex items-center justify-center p-4 z-[70]">
            <div className="bg-gray-800 p-6 rounded-xl shadow-2xl w-full max-w-md border border-pink-700">
                <h3 className="text-xl font-semibold text-pink-400 mb-4 flex items-center">
                    <LightBulbIcon /> {title}
                </h3>
                {isLoading ? (
                    <div className="flex justify-center items-center h-24">
                        <div className="w-8 h-8 border-4 border-t-transparent border-pink-400 rounded-full animate-spin"></div>
                        <p className="ml-3 text-gray-300">Đang tải gợi ý từ Đại Năng...</p>
                    </div>
                ) : suggestions.length > 0 ? (
                    <ul className="space-y-2 max-h-60 overflow-y-auto scrollbar-thin scrollbar-thumb-pink-500 scrollbar-track-gray-700">
                        {suggestions.map((suggestion, index) => (
                            <li key={index}>
                                <button
                                    onClick={() => { onSelect(suggestion); onClose(); }}
                                    className="w-full text-left p-3 bg-gray-700 hover:bg-gray-600/80 rounded-md text-gray-200 transition-colors shadow hover:shadow-md"
                                >
                                    {suggestion}
                                </button>
                            </li>
                        ))}
                    </ul>
                ) : (
                    <p className="text-gray-400 text-center py-4">Không có gợi ý nào được tạo ra. Hãy thử lại hoặc tự sáng tạo!</p>
                )}
                <button
                    onClick={onClose}
                    className="mt-6 w-full bg-gray-600 hover:bg-gray-500 text-white font-semibold py-2 px-4 rounded-lg"
                >
                    Đóng
                </button>
            </div>
        </div>
    );
}

// App Component
const App = () => {
  const [currentScreen, setCurrentScreen] = useState('initial');
  const [apiKey, setApiKey] = useState(''); 
  const [apiMode, setApiMode] = useState('defaultGemini'); 
  const [apiKeyStatus, setApiKeyStatus] = useState({ 
    status: 'Đang dùng Gemini AI Mặc Định', 
    message: 'Không cần API Key. Nội dung sẽ được tạo bởi AI của nền tảng.', 
    color: 'text-sky-400' 
  });
  const [gameSettings, setGameSettings] = useState({
    theme: '',
    setting: '',
    characterName: '',
    characterPersonality: PLAYER_PERSONALITIES[0], 
    characterGender: 'Không xác định',
    characterBackstory: '',
    preferredInitialSkill: '', 
    difficulty: 'Thường',
    difficultyDescription: '',
    allowNsfw: false, 
    initialWorldElements: [],
    useCharacterGoal: false, 
    characterGoal: '',   
    allowCustomActionInput: true, 
  });
  const [storyHistory, setStoryHistory] = useState([]); 
  const [currentStory, setCurrentStory] = useState('');
  const [choices, setChoices] = useState([]);
  const [isLoading, setIsLoading] = useState(false); 
  const [userId, setUserId] = useState(null);
  const [isAuthReady, setIsAuthReady] = useState(false);
  const [showApiModal, setShowApiModal] = useState(false);
  const [showUpdateLogModal, setShowUpdateLogModal] = useState(false); // New state for update log
  const [inputApiKey, setInputApiKey] = useState(''); 
  const [chatHistoryForGemini, setChatHistoryForGemini] = useState([]);
  const [currentGameId, setCurrentGameId] = useState(null);
  const [savedGames, setSavedGames] = useState([]);
  const [showLoadGameModal, setShowLoadGameModal] = useState(false);
  const [modalMessage, setModalMessage] = useState({ show: false, title: '', content: '', type: 'info' });
  const [confirmationModal, setConfirmationModal] = useState({ show: false, title: '', content: '', onConfirm: null, onCancel: null, confirmText: 'Xác nhận', cancelText: 'Hủy'});
  
  const [customActionInput, setCustomActionInput] = useState('');
  const [knowledgeBase, setKnowledgeBase] = useState({ 
    npcs: [], items: [], locations: [], companions: [], 
    inventory: [], playerSkills: [], relationships: [],
    playerStatus: [], quests: [], // Added quests to knowledgeBase
  });
  const [showCharacterInfoModal, setShowCharacterInfoModal] = useState(false);

  const [isFetchingSuggestions, setIsFetchingSuggestions] = useState(false);
  const [showSuggestionsModal, setShowSuggestionsModal] = useState({ show: false, fieldType: null, suggestions: [], isLoading: true, title: '' });
  const [isGeneratingContent, setIsGeneratingContent] = useState(false); 
  const [isGeneratingDifficultyDesc, setIsGeneratingDifficultyDesc] = useState(false);
  const [isGeneratingInitialElementDesc, setIsGeneratingInitialElementDesc] = useState({});
  const [isGeneratingGoal, setIsGeneratingGoal] = useState(false); 
  const [isGeneratingSuggestedActions, setIsGeneratingSuggestedActions] = useState(false);
  const [suggestedActionsList, setSuggestedActionsList] = useState([]);
  const [showSuggestedActionsModal, setShowSuggestedActionsModal] = useState(false);
  const [isGeneratingCharacterName, setIsGeneratingCharacterName] = useState(false);
  const [isGeneratingInitialSkill, setIsGeneratingInitialSkill] = useState(false);


  const [showQuickLoreModal, setShowQuickLoreModal] = useState(false);
  const [quickLoreContent, setQuickLoreContent] = useState(null);

  const [isProcessingAction, setIsProcessingAction] = useState(false); 

  const openQuickLoreModal = useCallback((category, nameOrTitle) => {
    let item = null;
    const categoryKey = category.toLowerCase();
    if (knowledgeBase && knowledgeBase[categoryKey]) {
        item = knowledgeBase[categoryKey].find(i => 
            (i.Name && i.Name.trim().toLowerCase() === nameOrTitle.trim().toLowerCase()) || 
            (i.NPC && i.NPC.trim().toLowerCase() === nameOrTitle.trim().toLowerCase()) ||
            (i.name && i.name.trim().toLowerCase() === nameOrTitle.trim().toLowerCase()) ||
            (i.title && i.title.trim().toLowerCase() === nameOrTitle.trim().toLowerCase()) // For quests
        );
    }
    if (item) {
        setQuickLoreContent({...item, category: categoryKey}); 
        setShowQuickLoreModal(true);
    } else {
        console.warn(`Quick lore not found for category '${categoryKey}', name/title '${nameOrTitle}'.`);
        setModalMessage({show: true, title: "Không Tìm Thấy", content: `Không tìm thấy thông tin chi tiết cho '${nameOrTitle}'.`, type: 'info'});
    }
  }, [knowledgeBase]);


  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (user) => {
      if (user) {
        setUserId(user.uid);
        const userApiKey = await loadApiKey(user.uid); 
        if (userApiKey) {
          setApiKey(userApiKey); 
          setInputApiKey(userApiKey); 
          setApiMode('userKey'); 
          setApiKeyStatus({ status: 'Đã kết nối', message: 'API Key của bạn đã được tải từ lưu trữ.', color: 'text-green-500' });
        } else {
          setApiMode('defaultGemini');
          setApiKeyStatus({ 
            status: 'Đang dùng Gemini AI Mặc Định', 
            message: 'Không cần API Key. Nội dung sẽ được tạo bởi AI của nền tảng.', 
            color: 'text-sky-400' 
          });
        }
      } else {
        try {
          if (typeof __initial_auth_token !== 'undefined' && __initial_auth_token) {
            await signInWithCustomToken(auth, __initial_auth_token);
          } else {
            await signInAnonymously(auth);
          }
        } catch (error) {
          console.error("Error during sign-in:", error);
          setApiKeyStatus({ status: 'Lỗi xác thực', message: `Không thể xác thực: ${error.message}`, color: 'text-red-500' });
        }
      }
      setIsAuthReady(true);
    });
    return () => unsubscribe();
  }, []);

  useEffect(() => {
    if (isAuthReady && userId) {
      const gamesCollectionPath = `artifacts/${appId}/users/${userId}/games`;
      const q = query(collection(db, gamesCollectionPath));
      const unsubscribe = onSnapshot(q, (querySnapshot) => {
        const games = [];
        querySnapshot.forEach((doc) => {
          games.push({ id: doc.id, ...doc.data() });
        });
        setSavedGames(games.sort((a, b) => (b.updatedAt?.toDate() || 0) - (a.updatedAt?.toDate() || 0)));
      }, (error) => {
        console.error("Error fetching saved games:", error);
        setModalMessage({ show: true, title: 'Lỗi Tải Game', content: `Không thể tải danh sách game đã lưu: ${error.message}`, type: 'error' });
      });
      return () => unsubscribe();
    }
  }, [isAuthReady, userId]);


  const handleInputChange = useCallback((e) => {
    const { name, value, type, checked } = e.target;
    setGameSettings((prev) => ({ 
        ...prev, 
        [name]: type === 'checkbox' ? checked : value
    }));
    if (name === "difficulty" && value !== "Tuỳ Chỉnh AI") {
        setGameSettings(prev => ({ ...prev, difficultyDescription: '' }));
    }
    if (name === "useCharacterGoal" && !checked) {
        setGameSettings(prev => ({ ...prev, characterGoal: '' }));
    }
  }, []);

  const addInitialWorldElement = () => {
    setGameSettings(prev => ({
        ...prev,
        initialWorldElements: [
            ...prev.initialWorldElements,
            { id: crypto.randomUUID(), type: 'NPC', name: '', description: '', personality: '' }
        ]
    }));
  };

  const removeInitialWorldElement = (id) => {
    setGameSettings(prev => ({
        ...prev,
        initialWorldElements: prev.initialWorldElements.filter(el => el.id !== id)
    }));
  };

  const handleInitialElementChange = (index, event) => {
    const { name, value } = event.target;
    setGameSettings(prev => {
        const updatedElements = [...prev.initialWorldElements];
        updatedElements[index] = { ...updatedElements[index], [name]: value };
        return { ...prev, initialWorldElements: updatedElements };
    });
  };

  const handleGenerateInitialElementDescription = async (index) => {
    if (apiMode === 'userKey' && !apiKey) {
        setModalMessage({ show: true, title: 'Thiếu API Key', content: 'Vui lòng thiết lập API Key.', type: 'error' });
        setShowApiModal(true);
        return;
    }
    const element = gameSettings.initialWorldElements[index];
    if (!element || !element.name) {
        setModalMessage({show: true, title: "Thiếu Tên", content: "Vui lòng nhập tên thực thể trước khi tạo mô tả.", type: "info"});
        return;
    }

    setIsGeneratingInitialElementDesc(prev => ({...prev, [element.id]: true}));
    
    const { theme, setting } = gameSettings; 
    const personalityInfo = element.type === 'NPC' && element.personality ? `Tính cách NPC đã cho: ${element.personality}.` : 'Tính cách NPC: AI tự quyết định cho phù hợp.';
    const promptText = `Dựa trên các thông tin sau:
    Chủ đề game: '${theme || "Chưa rõ"}'
    Bối cảnh game: '${setting || "Chưa rõ"}'
    Tên thực thể: '${element.name}'
    Loại thực thể: '${element.type}'
    ${personalityInfo}
    Hãy ✨ viết một mô tả ngắn gọn (1-3 câu, tối đa 150 chữ) bằng tiếng Việt cho thực thể này để sử dụng trong việc kiến tạo thế giới ban đầu của trò chơi phiêu lưu văn bản. Mô tả cần phù hợp với các thông tin đã cho. Phong cách viết nên theo tiểu thuyết mạng Trung Quốc.`;
    
    const generatedText = await fetchGenericGeminiText(promptText);
    if (generatedText) {
        setGameSettings(prev => {
            const updatedElements = [...prev.initialWorldElements];
            updatedElements[index] = { ...updatedElements[index], description: generatedText };
            return { ...prev, initialWorldElements: updatedElements };
        });
    }
    setIsGeneratingInitialElementDesc(prev => ({...prev, [element.id]: false}));
  };


  const saveApiKey = async () => { 
    if (!userId) {
      setModalMessage({ show: true, title: 'Lỗi', content: 'Người dùng chưa được xác thực để lưu API Key.', type: 'error' });
      return;
    }
    if (!inputApiKey.trim()) {
        setModalMessage({ show: true, title: 'Thiếu Thông Tin', content: 'API Key không được để trống.', type: 'error' });
        return;
    }
    setIsLoading(true); 
    try {
      const apiKeyRef = doc(db, `artifacts/${appId}/users/${userId}/apiCredentials/gemini`);
      await setDoc(apiKeyRef, { key: inputApiKey, lastUpdated: serverTimestamp() });
      setApiKey(inputApiKey); 
      setApiMode('userKey'); 
      setApiKeyStatus({ status: 'Đã lưu', message: 'API Key của bạn đã được lưu thành công!', color: 'text-green-500' });
      setShowApiModal(false);
      setModalMessage({ show: true, title: 'Thành Công', content: 'API Key của bạn đã được lưu!', type: 'success' });
    } catch (error) {
      console.error("Error saving API key:", error);
      setApiKeyStatus({ status: 'Lỗi', message: `Lưu API Key thất bại: ${error.message}`, color: 'text-red-500' });
      setModalMessage({ show: true, title: 'Lỗi Lưu API Key', content: `Lưu API Key thất bại: ${error.message}`, type: 'error' });
    }
    setIsLoading(false);
  };

  const loadApiKey = async (currentUserId) => {
    if (!currentUserId) return null;
    try {
      const apiKeyRef = doc(db, `artifacts/${appId}/users/${currentUserId}/apiCredentials/gemini`);
      const docSnap = await getDoc(apiKeyRef);
      if (docSnap.exists()) {
        return docSnap.data().key;
      }
      return null;
    } catch (error) {
      console.error("Error loading API key:", error);
      setModalMessage({ show: true, title: 'Lỗi Tải API Key', content: `Không thể tải API Key đã lưu: ${error.message}`, type: 'error' });
      return null;
    }
  };

  const testApiKey = async () => { 
    if (!inputApiKey) {
      setApiKeyStatus({ status: 'Chưa nhập Key', message: 'Vui lòng nhập API Key để kiểm tra.', color: 'text-yellow-500' });
      setModalMessage({ show: true, title: 'Thiếu Thông Tin', content: 'Vui lòng nhập API Key để kiểm tra.', type: 'info' });
      return;
    }
    setIsLoading(true);
    setApiKeyStatus({ status: 'Đang kiểm tra...', message: 'Vui lòng đợi.', color: 'text-blue-500' });

    const payload = {
      contents: [{ role: "user", parts: [{ text: "Xin chào! Đây là một bài kiểm tra kết nối." }] }],
    };
    const apiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${inputApiKey}`;

    try {
      const response = await fetch(apiUrl, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });
      const result = await response.json();

      if (response.ok && result.candidates && result.candidates.length > 0) {
        setApiKeyStatus({ status: 'Thành công (Key đang nhập)', message: 'API Key hợp lệ và kết nối thành công!', color: 'text-green-500' });
        setModalMessage({ show: true, title: 'Kiểm Tra Thành Công', content: 'API Key bạn vừa nhập hợp lệ!', type: 'success' });
      } else {
        const errorMessage = result.error?.message || `Mã lỗi ${response.status}. Vui lòng kiểm tra API Key và quyền truy cập.`;
        setApiKeyStatus({ status: 'Thất bại (Key đang nhập)', message: `Kiểm tra API Key thất bại: ${errorMessage}`, color: 'text-red-500' });
        setModalMessage({ show: true, title: 'Kiểm Tra Thất Bại', content: `Chi tiết: ${errorMessage}`, type: 'error' });
      }
    } catch (error) {
      console.error('Error testing API key:', error);
      setApiKeyStatus({ status: 'Lỗi Mạng (Key đang nhập)', message: `Lỗi kết nối: ${error.message}. Vui lòng kiểm tra mạng của bạn.`, color: 'text-red-500' });
      setModalMessage({ show: true, title: 'Lỗi Kết Nối', content: `Không thể kết nối đến API: ${error.message}`, type: 'error' });
    }
    setIsLoading(false);
  };
  
  const fetchGenericGeminiText = async (promptText) => {
    const effectiveApiKey = apiMode === 'defaultGemini' ? "" : apiKey;
    if (apiMode === 'userKey' && !effectiveApiKey) {
      setModalMessage({ show: true, title: 'Lỗi API Key', content: 'API Key của bạn chưa được cấu hình. Vui lòng vào Thiết Lập API.', type: 'error' });
      setShowApiModal(true);
      return null;
    }

    const payload = { contents: [{ role: "user", parts: [{ text: promptText }] }] };
    const apiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${effectiveApiKey}`;

    try {
      const response = await fetch(apiUrl, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });
      const result = await response.json();
      if (result.candidates && result.candidates[0]?.content?.parts[0]?.text) {
        return result.candidates[0].content.parts[0].text.trim(); // Trim the response
      } else {
        const errorMsg = result.error?.message || "Không thể lấy dữ liệu từ AI.";
        console.error("Gemini API error response:", JSON.stringify(result, null, 2));
        setModalMessage({ show: true, title: 'Lỗi AI', content: errorMsg, type: 'error' });
        return null;
      }
    } catch (error) {
      console.error('Error fetching generic Gemini text:', error);
      setModalMessage({ show: true, title: 'Lỗi Mạng', content: `Lỗi kết nối khi gọi AI: ${error.message}`, type: 'error' });
      return null;
    }
  };

  const handleFetchSuggestions = async (fieldType) => {
    if (apiMode === 'userKey' && !apiKey) {
      setModalMessage({ show: true, title: 'Thiếu API Key', content: 'Vui lòng thiết lập API Key để sử dụng tính năng này.', type: 'error' });
      setShowApiModal(true);
      return;
    }
    setIsFetchingSuggestions(true);
    setShowSuggestionsModal({ show: true, fieldType, suggestions: [], isLoading: true, title: fieldType === 'theme' ? "✨ Gợi Ý Chủ Đề" : "✨ Gợi Ý Bối Cảnh" });


    let promptText = '';
    if (fieldType === 'theme') {
      promptText = "Hãy gợi ý 5 chủ đề độc đáo và hấp dẫn bằng tiếng Việt cho một trò chơi phiêu lưu bằng văn bản (text adventure game) theo phong cách tiểu thuyết mạng Trung Quốc. Mỗi chủ đề trên một dòng, không cần đánh số đầu dòng.";
    } else if (fieldType === 'setting') {
      const currentTheme = gameSettings.theme || 'phiêu lưu chung';
      promptText = `Hãy gợi ý 5 bối cảnh (thế giới/môi trường) thú vị và chi tiết bằng tiếng Việt cho một trò chơi phiêu lưu bằng văn bản có chủ đề là '${currentTheme}' theo phong cách tiểu thuyết mạng Trung Quốc. Mỗi bối cảnh trên một dòng, không cần đánh số đầu dòng.`;
    }

    const suggestionsText = await fetchGenericGeminiText(promptText);
    if (suggestionsText) {
      const suggestionsArray = suggestionsText.split('\n').map(s => s.trim()).filter(s => s);
      setShowSuggestionsModal(prev => ({ ...prev, suggestions: suggestionsArray, isLoading: false }));
    } else {
      setShowSuggestionsModal(prev => ({ ...prev, suggestions: [], isLoading: false })); 
    }
    setIsFetchingSuggestions(false);
  };
  
  const handleGenerateBackstory = async () => {
     if (apiMode === 'userKey' && !apiKey) {
      setModalMessage({ show: true, title: 'Thiếu API Key', content: 'Vui lòng thiết lập API Key để sử dụng tính năng này.', type: 'error' });
      setShowApiModal(true);
      return;
    }
    setIsGeneratingContent(true);
    const { characterName, characterGender, theme, setting, characterPersonality } = gameSettings; 
    const personalityInfo = (characterPersonality && characterPersonality !== PLAYER_PERSONALITIES[0]) ? `Tính cách: ${characterPersonality}.` : 'Tính cách sẽ do người chơi chọn sau.';
    const promptText = `Dựa vào các thông tin sau: Tên nhân vật='${characterName || 'Nhân vật chính'}', Giới tính='${characterGender}', ${personalityInfo} Chủ đề game='${theme || 'Chưa rõ'}', Bối cảnh game='${setting || 'Chưa rõ'}', hãy ✨ viết một đoạn sơ lược tiểu sử hoặc đặc điểm nổi bật (khoảng 2-3 câu, tối đa 150 chữ) bằng tiếng Việt cho nhân vật này để sử dụng trong một trò chơi phiêu lưu bằng văn bản, theo văn phong tiểu thuyết mạng Trung Quốc. Tiểu sử nên phản ánh tính cách đã chọn (nếu có).`;
    
    const backstoryText = await fetchGenericGeminiText(promptText);
    if (backstoryText) {
      setGameSettings(prev => ({ ...prev, characterBackstory: backstoryText }));
    }
    setIsGeneratingContent(false);
  };

  const handleGenerateDifficultyDescription = async () => {
    if (apiMode === 'userKey' && !apiKey) {
        setModalMessage({ show: true, title: 'Thiếu API Key', content: 'Vui lòng thiết lập API Key để sử dụng tính năng này.', type: 'error' });
        setShowApiModal(true);
        return;
    }
    setIsGeneratingDifficultyDesc(true);
    const { theme, setting } = gameSettings;
    const promptText = `Dựa trên chủ đề game là '${theme || "Chưa rõ"}' và bối cảnh '${setting || "Chưa rõ"}', hãy ✨ viết một mô tả ngắn gọn (1-2 câu, tối đa 100 chữ) bằng tiếng Việt về độ khó "Tuỳ Chỉnh AI" cho trò chơi này, theo văn phong tiểu thuyết mạng Trung Quốc. Mô tả này nên gợi ý về những thử thách hoặc đặc điểm riêng của độ khó này.`;
    
    const descText = await fetchGenericGeminiText(promptText);
    if (descText) {
        setGameSettings(prev => ({ ...prev, difficultyDescription: descText }));
    }
    setIsGeneratingDifficultyDesc(false);
  };

  const handleGenerateGoal = async () => {
    if (apiMode === 'userKey' && !apiKey) {
        setModalMessage({ show: true, title: 'Thiếu API Key', content: 'Vui lòng thiết lập API Key.', type: 'error' });
        setShowApiModal(true);
        return;
    }
    setIsGeneratingGoal(true);
    const { theme, setting, characterPersonality, characterBackstory } = gameSettings; 
    const personalityInfo = (characterPersonality && characterPersonality !== PLAYER_PERSONALITIES[0]) ? `Tính cách nhân vật: ${characterPersonality}.` : '';
    const backstoryInfo = characterBackstory ? `Tiểu sử nhân vật: ${characterBackstory}.` : '';

    const promptText = `Dựa trên các thông tin sau:
    Chủ đề game: '${theme || "Chưa rõ"}'
    Bối cảnh game: '${setting || "Chưa rõ"}'
    ${personalityInfo}
    ${backstoryInfo}
    Hãy ✨ gợi ý 3-4 mục tiêu hoặc động lực chính (khoảng 10-25 từ mỗi mục tiêu) bằng tiếng Việt cho nhân vật chính trong một trò chơi phiêu lưu văn bản. Các mục tiêu này nên phù hợp với thông tin đã cho và có thể tạo ra những diễn biến thú vị trong game. Trả về các gợi ý, mỗi gợi ý trên một dòng, không cần đánh số.`;
    
    const generatedText = await fetchGenericGeminiText(promptText);
    if (generatedText) {
        const suggestionsArray = generatedText.split('\n').map(s => s.trim()).filter(s => s);
        setShowSuggestionsModal({ 
            show: true, 
            fieldType: 'characterGoal', 
            suggestions: suggestionsArray, 
            isLoading: false,
            title: "✨ Gợi Ý Mục Tiêu/Động Lực"
        });
    } else {
        setModalMessage({show:true, title: "Không có gợi ý", content: "AI không thể tạo gợi ý mục tiêu lúc này. Hãy thử lại hoặc tự điền.", type: "info"})
    }
    setIsGeneratingGoal(false);
  };

  const handleGenerateCharacterName = async () => {
    if (apiMode === 'userKey' && !apiKey) {
        setModalMessage({ show: true, title: 'Thiếu API Key', content: 'Vui lòng thiết lập API Key.', type: 'error' });
        setShowApiModal(true);
        return;
    }
    setIsGeneratingCharacterName(true);
    const { theme, setting, characterGender } = gameSettings;
    const genderPrompt = characterGender === 'Không xác định' ? 'phi giới tính hoặc để AI tự quyết' : characterGender;
    const promptText = `Dựa trên chủ đề game là '${theme || "Chưa rõ"}', bối cảnh '${setting || "Chưa rõ"}', và giới tính nhân vật là '${genderPrompt}', hãy ✨ gợi ý MỘT tên nhân vật bằng tiếng Việt theo phong cách tiểu thuyết mạng Trung Quốc. Chỉ trả về tên nhân vật đó, không thêm bất kỳ lời giải thích nào.`;
    
    const generatedName = await fetchGenericGeminiText(promptText);
    if (generatedName) {
        setGameSettings(prev => ({ ...prev, characterName: generatedName.split('\n')[0].trim() })); // Take first line if multiple
    }
    setIsGeneratingCharacterName(false);
  };

  const handleGenerateInitialSkill = async () => {
    if (apiMode === 'userKey' && !apiKey) {
        setModalMessage({ show: true, title: 'Thiếu API Key', content: 'Vui lòng thiết lập API Key.', type: 'error' });
        setShowApiModal(true);
        return;
    }
    setIsGeneratingInitialSkill(true);
    const { theme, setting, characterName, characterPersonality, characterBackstory } = gameSettings;
    const promptText = `Dựa trên chủ đề game '${theme || "Chưa rõ"}', bối cảnh '${setting || "Chưa rõ"}', tên nhân vật '${characterName || "Nhân vật chính"}', tính cách '${characterPersonality}', và sơ lược tiểu sử '${characterBackstory || "Chưa rõ"}', hãy ✨ gợi ý MỘT kỹ năng khởi đầu phù hợp bằng tiếng Việt (ví dụ: 'Hỏa Cầu Thuật sơ cấp', 'Ẩn Thân Thuật'). Chỉ trả về tên kỹ năng đó, không thêm mô tả chi tiết hay lời giải thích.`;

    const generatedSkill = await fetchGenericGeminiText(promptText);
    if (generatedSkill) {
        setGameSettings(prev => ({ ...prev, preferredInitialSkill: generatedSkill.split('\n')[0].trim() })); // Take first line
    }
    setIsGeneratingInitialSkill(false);
  };


  const handleGenerateSuggestedActions = async () => {
    if (apiMode === 'userKey' && !apiKey) {
        setModalMessage({ show: true, title: 'Thiếu API Key', content: 'Vui lòng thiết lập API Key.', type: 'error' });
        setShowApiModal(true);
        return;
    }
    setIsGeneratingSuggestedActions(true);
    setSuggestedActionsList([]);

    const lastStoryItem = storyHistory.filter(item => item.type === 'story').pop()?.content || "Chưa có diễn biến.";
    const inventoryString = knowledgeBase.inventory.map(item => `${item.Name} (${item.Description || 'không rõ'})`).join(', ') || "trống";
    const skillsString = knowledgeBase.playerSkills.map(skill => `${skill.Name} (${skill.Description || 'không rõ'})`).join(', ') || "chưa có";
    const statusesString = knowledgeBase.playerStatus.map(status => `${status.name} (Ảnh hưởng: ${status.effects || 'không rõ'})`).join('; ') || "không có";
    const currentPersonality = gameSettings.characterPersonality; 
    const activeQuestsString = knowledgeBase.quests.filter(q => q.status === 'active').map(q => `${q.title} (Mục tiêu: ${q.objectives?.filter(o => !o.completed).map(o=>o.text).join(', ') || 'Hoàn thành các bước tiếp theo'})`).join('; ') || "không có";
    
    const promptText = `Bối cảnh hiện tại: ${lastStoryItem}
    Nhân vật chính: ${gameSettings.characterName || 'Nhân vật chính'}, Tính cách: ${currentPersonality}.
    Mục tiêu chính: ${gameSettings.useCharacterGoal && gameSettings.characterGoal ? gameSettings.characterGoal : 'Chưa rõ hoặc không có'}.
    Nhiệm vụ đang hoạt động: ${activeQuestsString}.
    Balo đồ: ${inventoryString}.
    Kỹ năng: ${skillsString}.
    Trạng thái hiện tại: ${statusesString}.
    Dựa vào tình hình trên, hãy ✨ gợi ý 3-4 hành động tùy ý ngắn gọn, thực tế và phù hợp bằng tiếng Việt mà nhân vật có thể thực hiện. Các hành động này NÊN liên quan đến nhiệm vụ đang hoạt động (nếu có) hoặc mục tiêu chính. Mỗi gợi ý trên một dòng, không đánh số. Ví dụ: "Thử dùng [Tên Kỹ Năng] lên [Đối Tượng]", "Hỏi [Tên NPC] về [Sự Việc]", "Kiểm tra [Đồ Vật] kỹ hơn". Cân nhắc các trạng thái hiện tại khi đưa ra gợi ý. Với một số hành động có rủi ro, hãy ghi chú thêm (Tỷ lệ thành công: Cao/Trung Bình/Thấp. Rủi ro: ... Phần thưởng: ...).`;

    const suggestionsText = await fetchGenericGeminiText(promptText);
    if (suggestionsText) {
        const suggestionsArray = suggestionsText.split('\n').map(s => s.trim()).filter(s => s);
        setSuggestedActionsList(suggestionsArray);
        setShowSuggestedActionsModal(true);
    } else {
        setModalMessage({show:true, title: "Không có gợi ý", content: "AI không thể tạo gợi ý hành động lúc này.", type: "info"})
    }
    setIsGeneratingSuggestedActions(false);
  };


  const parseGeminiResponseAndUpdateState = (text) => {
    let storyContent = text;
    let extractedChoices = [];
    
    const newKnowledgeUpdates = { 
        npcs: [], items: [], locations: [], companions: [], 
        inventory: [], playerSkills: [], relationships: [],
        playerStatus: [], quests: [], 
        _removePlayerStatusByName: [], 
        _updateNpcStatus: [], 
        _updateQuest: [], // For updating existing quests
        _updateQuestObjective: [], // For updating quest objectives
    };

    const tagPatterns = {
        LORE_NPC: /\[LORE_NPC:\s*([^\]]+)\]/gs,
        LORE_ITEM: /\[LORE_ITEM:\s*([^\]]+)\]/gs,
        LORE_LOCATION: /\[LORE_LOCATION:\s*([^\]]+)\]/gs,
        COMPANION: /\[COMPANION:\s*([^\]]+)\]/gs,
        ITEM_AQUIRED: /\[ITEM_AQUIRED:\s*([^\]]+)\]/gs,
        SKILL_LEARNED: /\[SKILL_LEARNED:\s*([^\]]+)\]/gs,
        RELATIONSHIP_CHANGED: /\[RELATIONSHIP_CHANGED:\s*([^\]]+)\]/gs,
        ITEM_CONSUMED: /\[ITEM_CONSUMED:\s*([^\]]+)\]/gs, 
        ITEM_UPDATED: /\[ITEM_UPDATED:\s*([^\]]+)\]/gs,   
        STATUS_APPLIED_SELF: /\[STATUS_APPLIED_SELF:\s*([^\]]+)\]/gs,
        STATUS_CURED_SELF: /\[STATUS_CURED_SELF:\s*Name="([^"]+)"\]/gs, 
        STATUS_EXPIRED_SELF: /\[STATUS_EXPIRED_SELF:\s*Name="([^"]+)"\]/gs, 
        STATUS_APPLIED_NPC: /\[STATUS_APPLIED_NPC:\s*([^\]]+)\]/gs,
        STATUS_CURED_NPC: /\[STATUS_CURED_NPC:\s*NPCName="([^"]+)",\s*StatusName="([^"]+)"\]/gs,
        STATUS_EXPIRED_NPC: /\[STATUS_EXPIRED_NPC:\s*NPCName="([^"]+)",\s*StatusName="([^"]+)"\]/gs,
        QUEST_ASSIGNED: /\[QUEST_ASSIGNED:\s*([^\]]+)\]/gs,
        QUEST_UPDATED: /\[QUEST_UPDATED:\s*([^\]]+)\]/gs,
        QUEST_OBJECTIVE_COMPLETED: /\[QUEST_OBJECTIVE_COMPLETED:\s*([^\]]+)\]/gs,
    };

    const categoryMap = {
        LORE_NPC: 'npcs', LORE_ITEM: 'items', LORE_LOCATION: 'locations',
        COMPANION: 'companions', ITEM_AQUIRED: 'inventory', SKILL_LEARNED: 'playerSkills',
        RELATIONSHIP_CHANGED: 'relationships', ITEM_CONSUMED: 'inventory', ITEM_UPDATED: 'inventory',
        STATUS_APPLIED_SELF: 'playerStatus', QUEST_ASSIGNED: 'quests',
    };

    for (const tagType in tagPatterns) {
        const regex = tagPatterns[tagType];
        let match;
        const matchesToReplace = [];

        while ((match = regex.exec(storyContent)) !== null) {
            matchesToReplace.push(match[0]);
            const dataString = match[1];
            try {
                if (tagType === 'STATUS_CURED_SELF' || tagType === 'STATUS_EXPIRED_SELF') {
                    newKnowledgeUpdates._removePlayerStatusByName.push(match[1]); 
                } else if (tagType === 'STATUS_APPLIED_NPC') {
                    const parsedData = parseKeyValueString(match[1]); 
                    if (parsedData.NPCName && parsedData.Name) {
                         newKnowledgeUpdates._updateNpcStatus.push({ 
                            npcName: parsedData.NPCName, 
                            status: { id: crypto.randomUUID(), ...parsedData, NPCName: undefined } 
                        });
                    }
                } else if (tagType === 'STATUS_CURED_NPC' || tagType === 'STATUS_EXPIRED_NPC') {
                     newKnowledgeUpdates._updateNpcStatus.push({ 
                        npcName: match[1], 
                        removeStatusName: match[2] 
                    });
                } else if (tagType === 'QUEST_UPDATED') {
                    const parsedData = parseKeyValueString(dataString);
                    if (parsedData.title) {
                        newKnowledgeUpdates._updateQuest.push(parsedData);
                    }
                } else if (tagType === 'QUEST_OBJECTIVE_COMPLETED') {
                    const parsedData = parseKeyValueString(dataString);
                    if (parsedData.questTitle && parsedData.objectiveDescription) {
                        newKnowledgeUpdates._updateQuestObjective.push(parsedData);
                    }
                }
                else { 
                    const parsedData = parseKeyValueString(dataString);
                    const categoryKey = categoryMap[tagType];

                    if (parsedData.Name || parsedData.NPC || (categoryKey === 'playerStatus' && parsedData.name) || (categoryKey === 'quests' && parsedData.title)) { 
                        const uniqueIdKey = parsedData.Name || parsedData.NPC || parsedData.name || parsedData.title;
                        let itemWithId = { id: crypto.randomUUID(), ...parsedData, name: parsedData.name || parsedData.Name }; 
                        
                        if (categoryKey === 'quests') {
                            itemWithId.objectives = parsedData.objectives ? parsedData.objectives.split(';').map(objText => ({ text: objText.trim(), completed: false })) : [];
                            itemWithId.status = parsedData.status || 'active'; // Default to active
                        }


                        if (tagType === 'ITEM_CONSUMED') {
                            if (!newKnowledgeUpdates._toRemove) newKnowledgeUpdates._toRemove = [];
                            newKnowledgeUpdates._toRemove.push({ category: categoryKey, name: itemWithId.Name });
                        } else if (tagType === 'ITEM_UPDATED') {
                            if (!newKnowledgeUpdates._toUpdate) newKnowledgeUpdates._toUpdate = [];
                            newKnowledgeUpdates._toUpdate.push({ category: categoryKey, data: itemWithId });
                        } else {
                             if (!newKnowledgeUpdates[categoryKey]) newKnowledgeUpdates[categoryKey] = [];
                             newKnowledgeUpdates[categoryKey].push(itemWithId);
                        }
                    }
                }
            } catch (e) {
                console.error(`Error parsing ${tagType} string:`, dataString, e);
            }
        }
        matchesToReplace.forEach(matchStr => storyContent = storyContent.replace(matchStr, "").trim());
    }
    
    setKnowledgeBase(prev => {
        let updatedKnowledge = JSON.parse(JSON.stringify(prev)); 

        for (const categoryKey in newKnowledgeUpdates) {
            if (categoryKey.startsWith('_')) continue; 

            if (newKnowledgeUpdates[categoryKey] && newKnowledgeUpdates[categoryKey].length > 0) {
                if (!updatedKnowledge[categoryKey]) updatedKnowledge[categoryKey] = [];
                
                newKnowledgeUpdates[categoryKey].forEach(newItem => {
                    const uniqueKey = newItem.Name || newItem.NPC || newItem.name || newItem.title; 
                    const existingIndex = updatedKnowledge[categoryKey].findIndex(existingItem => 
                        ((existingItem.Name && existingItem.Name.trim().toLowerCase() === uniqueKey.trim().toLowerCase()) ||
                         (existingItem.NPC && existingItem.NPC.trim().toLowerCase() === uniqueKey.trim().toLowerCase()) ||
                         (existingItem.name && existingItem.name.trim().toLowerCase() === uniqueKey.trim().toLowerCase()) ||
                         (existingItem.title && existingItem.title.trim().toLowerCase() === uniqueKey.trim().toLowerCase())) 
                    );
                    if (existingIndex > -1) { 
                        updatedKnowledge[categoryKey][existingIndex] = { ...updatedKnowledge[categoryKey][existingIndex], ...newItem };
                    } else { 
                        updatedKnowledge[categoryKey].push(newItem);
                    }
                });
            }
        }
        
        if (newKnowledgeUpdates._toUpdate) {
            newKnowledgeUpdates._toUpdate.forEach(updateInstruction => {
                const { category, data } = updateInstruction;
                if (updatedKnowledge[category]) {
                    const itemIndex = updatedKnowledge[category].findIndex(item => item.Name === data.Name);
                    if (itemIndex > -1) {
                        updatedKnowledge[category][itemIndex] = { ...updatedKnowledge[category][itemIndex], ...data };
                        if (updatedKnowledge[category][itemIndex].Consumable && 
                            typeof updatedKnowledge[category][itemIndex].Uses === 'number' &&
                            updatedKnowledge[category][itemIndex].Uses <= 0) {
                             updatedKnowledge[category].splice(itemIndex, 1);
                        }
                    }
                }
            });
        }
        if (newKnowledgeUpdates._toRemove) { 
            newKnowledgeUpdates._toRemove.forEach(removalInstruction => {
                const { category, name } = removalInstruction;
                if (updatedKnowledge[category]) {
                    updatedKnowledge[category] = updatedKnowledge[category].filter(item => item.Name !== name);
                }
            });
        }

        if (newKnowledgeUpdates._removePlayerStatusByName.length > 0) {
            updatedKnowledge.playerStatus = updatedKnowledge.playerStatus.filter(status => 
                !newKnowledgeUpdates._removePlayerStatusByName.includes(status.name)
            );
        }
        
        if (newKnowledgeUpdates._updateNpcStatus.length > 0) {
            newKnowledgeUpdates._updateNpcStatus.forEach(update => {
                const npcIndex = updatedKnowledge.npcs.findIndex(npc => npc.Name === update.npcName);
                if (npcIndex > -1) {
                    if (!updatedKnowledge.npcs[npcIndex].statuses) {
                        updatedKnowledge.npcs[npcIndex].statuses = [];
                    }
                    if (update.status) { 
                        const existingStatusIndex = updatedKnowledge.npcs[npcIndex].statuses.findIndex(s => s.name === update.status.name);
                        if (existingStatusIndex > -1) {
                            updatedKnowledge.npcs[npcIndex].statuses[existingStatusIndex] = {...updatedKnowledge.npcs[npcIndex].statuses[existingStatusIndex], ...update.status};
                        } else {
                            updatedKnowledge.npcs[npcIndex].statuses.push(update.status);
                        }
                    } else if (update.removeStatusName) { 
                        updatedKnowledge.npcs[npcIndex].statuses = updatedKnowledge.npcs[npcIndex].statuses.filter(
                            s => s.name !== update.removeStatusName
                        );
                    }
                }
            });
        }

        // Handle Quest Updates
        if (newKnowledgeUpdates._updateQuest.length > 0) {
            newKnowledgeUpdates._updateQuest.forEach(questUpdateData => {
                const questIndex = updatedKnowledge.quests.findIndex(q => q.title === questUpdateData.title);
                if (questIndex > -1) {
                    updatedKnowledge.quests[questIndex] = { ...updatedKnowledge.quests[questIndex], ...questUpdateData };
                    // If an objective was completed via this tag, mark it.
                    if (questUpdateData.objectiveCompleted && updatedKnowledge.quests[questIndex].objectives) {
                        const objIndex = updatedKnowledge.quests[questIndex].objectives.findIndex(obj => obj.text === questUpdateData.objectiveCompleted);
                        if (objIndex > -1) {
                            updatedKnowledge.quests[questIndex].objectives[objIndex].completed = true;
                        }
                    }
                }
            });
        }
        // Handle Quest Objective Completion
        if (newKnowledgeUpdates._updateQuestObjective.length > 0) {
            newKnowledgeUpdates._updateQuestObjective.forEach(objUpdateData => {
                const questIndex = updatedKnowledge.quests.findIndex(q => q.title === objUpdateData.questTitle);
                if (questIndex > -1 && updatedKnowledge.quests[questIndex].objectives) {
                    const objIndex = updatedKnowledge.quests[questIndex].objectives.findIndex(obj => obj.text === objUpdateData.objectiveDescription);
                    if (objIndex > -1) {
                        updatedKnowledge.quests[questIndex].objectives[objIndex].completed = true;
                    }
                }
            });
        }

        return updatedKnowledge;
    });


    const lines = storyContent.split('\n');
    const potentialChoicesLines = [];
    let choiceStartIndex = -1;

    for (let i = lines.length - 1; i >= 0; i--) {
        const line = lines[i].trim();
        if (line.match(/^\d+\.\s*.+/) || line.match(/^[-*]\s*.+/)) {
            potentialChoicesLines.unshift(line); 
            choiceStartIndex = i;
        } else if (choiceStartIndex !== -1 && line === "") {
        } else if (choiceStartIndex !== -1 && line !== "") {
            break; 
        }
    }
    
    if (choiceStartIndex !== -1) { 
        extractedChoices = potentialChoicesLines.map(line => line.replace(/^\d+\.\s*/, '').replace(/^[-*]\s*/, '').trim()).filter(choice => choice !== "");
        storyContent = lines.slice(0, choiceStartIndex).join('\n').trim();
    } else {
        storyContent = lines.join('\n').trim(); 
    }
    
    return { story: storyContent, choices: extractedChoices };
};


  const callGeminiAPI = async (prompt, isInitialCall = false) => {
    const effectiveApiKey = apiMode === 'defaultGemini' ? "" : apiKey;
    if (apiMode === 'userKey' && !effectiveApiKey) {
      setModalMessage({ show: true, title: 'Lỗi API Key', content: 'API Key của bạn chưa được cấu hình. Vui lòng vào Thiết Lập API.', type: 'error' });
      setIsLoading(false); 
      setShowApiModal(true);
      return;
    }
    
    if (!isInitialCall && !isProcessingAction) setIsLoading(true); 
    else if (isInitialCall) setIsLoading(true);


    let currentChatHistory = chatHistoryForGemini;
    if (isInitialCall) {
      currentChatHistory = [{ role: "user", parts: [{ text: prompt }] }];
      setKnowledgeBase({ 
        npcs: [], items: [], locations: [], companions: [], 
        inventory: [], playerSkills: [], relationships: [],
        playerStatus: [], quests: [], // Reset quests
      });
    } else {
      currentChatHistory.push({ role: "user", parts: [{ text: prompt }] });
    }
    
    const MAX_HISTORY_LENGTH = 20; 
    if (currentChatHistory.length > MAX_HISTORY_LENGTH) {
        const systemPromptIndex = currentChatHistory.findIndex(msg => msg.role === "system"); 
        const historyToKeep = currentChatHistory.slice(currentChatHistory.length - MAX_HISTORY_LENGTH);
        if (systemPromptIndex !== -1 && systemPromptIndex < (currentChatHistory.length - MAX_HISTORY_LENGTH) ) {
             currentChatHistory = [currentChatHistory[systemPromptIndex], ...historyToKeep];
        } else {
            currentChatHistory = historyToKeep;
        }
    }
    setChatHistoryForGemini(currentChatHistory);

    const payload = {
      contents: currentChatHistory,
      generationConfig: {} 
    };
    const apiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${effectiveApiKey}`;

    try {
      const response = await fetch(apiUrl, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });
      const result = await response.json();

      if (result.candidates && result.candidates.length > 0 && result.candidates[0].content && result.candidates[0].content.parts) {
        const rawText = result.candidates[0].content.parts[0].text;
        const { story, choices: newChoices } = parseGeminiResponseAndUpdateState(rawText);

        setCurrentStory(story);
        setChoices(newChoices); 
        
        const newStoryEntry = { type: 'story', content: story };
        
        setStoryHistory(prevStoryHistory => {
            const updatedStoryHistory = [...prevStoryHistory, newStoryEntry];
            if (currentGameId) {
                 saveGameProgress(currentGameId, story, newChoices, updatedStoryHistory, 
                                 [...currentChatHistory, { role: "model", parts: [{ text: rawText }] }], 
                                 knowledgeBase); 
            }
            return updatedStoryHistory;
        });
        
        const updatedChatHistory = [...currentChatHistory, { role: "model", parts: [{ text: rawText }] }];
        setChatHistoryForGemini(updatedChatHistory);

      } else {
        let errorText = "Không nhận được phản hồi hợp lệ từ Gemini.";
        if (result.error) {
            errorText = `Lỗi từ API Gemini: ${result.error.message} (Mã: ${result.error.code})`;
             if (result.error.code === 400 && result.error.message.toLowerCase().includes("api key not valid")) {
                errorText += ". Vui lòng kiểm tra lại API Key của bạn.";
                setApiKeyStatus({ status: 'Lỗi API Key', message: 'API Key không hợp lệ. Vui lòng kiểm tra lại.', color: 'text-red-500' });
                setShowApiModal(true);
            }
        } else if (response.status === 429) {
            errorText = "Lỗi từ API Gemini: Bạn đã gửi quá nhiều yêu cầu. Vui lòng thử lại sau.";
        }
        setCurrentStory(errorText);
        setChoices([]);
        setStoryHistory(prev => [...prev, { type: 'system', content: errorText }]);
        setModalMessage({ show: true, title: 'Lỗi API', content: errorText, type: 'error' });
      }
    } catch (error) {
      console.error('Error calling Gemini API:', error);
      const networkError = `Lỗi kết nối đến Gemini API: ${error.message}. Vui lòng kiểm tra kết nối mạng.`;
      setCurrentStory(networkError);
      setChoices([]);
      setStoryHistory(prev => [...prev, { type: 'system', content: networkError }]);
      setModalMessage({ show: true, title: 'Lỗi Mạng', content: networkError, type: 'error' });
    }
    if (!isProcessingAction) setIsLoading(false); 
  };

  const initializeGame = async () => {
    if (!gameSettings.theme || !gameSettings.setting || !gameSettings.characterName || !gameSettings.characterBackstory) {
        setModalMessage({ show: true, title: 'Thiếu Thông Tin', content: 'Vui lòng điền đầy đủ thông tin Chủ đề, Bối cảnh, Tên nhân vật và Sơ lược tiểu sử.', type: 'error' });
        return;
    }
    if (gameSettings.difficulty === "Tuỳ Chỉnh AI" && !gameSettings.difficultyDescription) {
        setModalMessage({ show: true, title: 'Thiếu Mô Tả Độ Khó', content: 'Vui lòng tạo hoặc nhập mô tả cho độ khó "Tuỳ Chỉnh AI".', type: 'error' });
        return;
    }
     if (gameSettings.useCharacterGoal && !gameSettings.characterGoal) {
        setModalMessage({ show: true, title: 'Thiếu Mục Tiêu', content: 'Vui lòng điền mục tiêu cho nhân vật hoặc tắt tùy chọn này.', type: 'error' });
        return;
    }
    if (apiMode === 'userKey' && !apiKey) {
      setModalMessage({ show: true, title: 'Thiếu API Key', content: 'Vui lòng thiết lập API Key của bạn hoặc chọn chế độ AI mặc định.', type: 'error' });
      setShowApiModal(true);
      return;
    }

    setCurrentStory('');
    setChoices([]);
    setStoryHistory([]);
    setChatHistoryForGemini([]); 
    setKnowledgeBase({ 
        npcs: [], items: [], locations: [], companions: [], 
        inventory: [], playerSkills: [], relationships: [],
        playerStatus: [], quests: [], 
    }); 

    const initialWorldElementsString = gameSettings.initialWorldElements
        .map(el => `- Loại: ${el.type}, Tên: ${el.name}, Mô tả: ${el.description}${el.type === 'NPC' && el.personality ? `, Tính cách NPC đã cho: ${el.personality}` : ''}`)
        .join('\n');
    
    const playerPersonalityInstruction = `Tính cách nhân vật chính: "${gameSettings.characterPersonality}". Hãy để tính cách này ảnh hưởng mạnh mẽ đến lời nói, suy nghĩ, hành động của nhân vật và cách thế giới phản ứng với họ. Đây là yếu tố CỐT LÕI.`; 
    
    const characterGoalInstruction = gameSettings.useCharacterGoal && gameSettings.characterGoal 
        ? `Mục tiêu/Động lực chính của nhân vật: "${gameSettings.characterGoal}". Mục tiêu này PHẢI là kim chỉ nam cho hành động, suy nghĩ của nhân vật và ảnh hưởng đến các sự kiện trong game. Đây là yếu tố CỐT LÕI.`
        : "Nhân vật không có mục tiêu/động lực cụ thể ban đầu. Hãy để câu chuyện tự nhiên phát triển hoặc tạo ra một động lực ban đầu dựa trên tình huống khởi đầu.";

    const initialPrompt = `
        Bạn là một Đại Năng kể chuyện, chuyên sáng tác tiểu thuyết mạng Trung Quốc thể loại '${gameSettings.theme}'. Văn phong của bạn cần đậm chất của thể loại này, sử dụng các cách xưng hô như 'bản tọa', 'lão phu', 'tiểu tử', 'ngươi', 'hắn', 'nàng', 'bổn cô nương', 'các hạ', 'đạo hữu', tránh dùng 'tôi', 'bạn', 'anh ấy', 'cô ấy'.
        QUAN TRỌNG VỀ TÍNH LIÊN TỤC: Luôn ghi nhớ và bám sát các sự kiện, nhân vật, địa điểm, và nhiệm vụ đã được giới thiệu. Câu chuyện phải diễn ra một cách logic, tránh thay đổi đột ngột hoặc quên mất chi tiết quan trọng.

        Thông tin đầu vào từ người dùng:
        Chủ đề: ${gameSettings.theme}
        Bối cảnh: ${gameSettings.setting}
        Độ khó: ${gameSettings.difficulty} ${gameSettings.difficultyDescription ? `(${gameSettings.difficultyDescription})` : ''}
        Nhân vật chính: Tên - ${gameSettings.characterName}, Giới tính - ${gameSettings.characterGender}, Sơ lược - ${gameSettings.characterBackstory}.
        ${playerPersonalityInstruction}
        ${characterGoalInstruction}
        Kỹ năng khởi đầu mong muốn: ${gameSettings.preferredInitialSkill || 'Không có, để AI quyết định'}
        Cho phép nội dung NSFW: ${gameSettings.allowNsfw ? 'Có' : 'Không'}. Nếu 'Có', hãy mô tả các cảnh 18+ (tình dục, bạo lực) một cách chi tiết, trần trụi và không ngần ngại, phù hợp với tính cách nhân vật và bối cảnh.
        Cho phép nhập hành động tùy ý: ${gameSettings.allowCustomActionInput ? 'Có' : 'Không'}. Nếu 'Không', người chơi chỉ có thể chọn từ các lựa chọn AI cung cấp.
        Các thực thể ban đầu trong thế giới (nếu có):
        ${initialWorldElementsString || 'Không có thực thể ban đầu nào được định nghĩa.'}

        Yêu cầu cụ thể về HỆ THỐNG TRẠNG THÁI, NHIỆM VỤ, TỶ LỆ THÀNH CÔNG và CÁC THẺ:
        1.  Bắt đầu câu chuyện. Tính cách nhân vật chính ("${gameSettings.characterPersonality}") và mục tiêu ("${gameSettings.characterGoal || 'chưa có'}") PHẢI ảnh hưởng RÕ RỆT đến cách nhân vật hành xử, lựa chọn ban đầu và diễn biến mở đầu.
        2.  Khi nhân vật (hoặc NPC) nhận một trạng thái mới (buff, debuff, injury), dùng thẻ:
            [STATUS_APPLIED_SELF: name="Tên Trạng Thái", description="Mô tả", type="buff/debuff/injury/neutral", duration="X lượt/Vĩnh viễn/Đến khi được chữa/Tự hết sau X sự kiện", effects="Ảnh hưởng cụ thể", cureConditions="Vật phẩm:Tên/Hành động:Tên/Tự hết/Không thể chữa", source="Nguồn gốc"]
            [STATUS_APPLIED_NPC: NPCName="Tên NPC", name="Tên Trạng Thái", description="...", type="...", duration="...", effects="...", cureConditions="...", source="..."]
        3.  Khi trạng thái của nhân vật chính được chữa khỏi hoặc hết hạn, dùng: [STATUS_CURED_SELF: Name="Tên Trạng Thái"] hoặc [STATUS_EXPIRED_SELF: Name="Tên Trạng Thái"].
        4.  Khi trạng thái của NPC được chữa khỏi hoặc hết hạn, dùng: [STATUS_CURED_NPC: NPCName="Tên NPC", StatusName="Tên Trạng Thái"] hoặc [STATUS_EXPIRED_NPC: NPCName="Tên NPC", StatusName="Tên Trạng Thái"].
        5.  Các trạng thái PHẢI có ảnh hưởng thực tế đến câu chuyện, lựa chọn, hoặc khả năng của nhân vật/NPC.
        6.  Nếu có "Kỹ năng khởi đầu mong muốn", hãy tạo một kỹ năng phù hợp và thông báo bằng thẻ [SKILL_LEARNED: Name="Tên Kỹ Năng", Description="Mô tả", Type="Loại Kỹ Năng"]. Nếu không, tự tạo một kỹ năng ban đầu phù hợp.
        7.  Nếu có "Các thực thể ban đầu trong thế giới", hãy tìm cách đưa chúng vào câu chuyện một cách tự nhiên. Với NPC, AI tự quyết định tính cách nếu người dùng không cung cấp và dùng thẻ [LORE_NPC: Name="...", Description="...", Personality="..."], [LORE_ITEM: Name="...", Description="...", Type="..."], hoặc [LORE_LOCATION: Name="...", Description="..."] tương ứng.
        8.  Nếu nhân vật bắt đầu với vật phẩm trong balo, sử dụng thẻ [ITEM_AQUIRED: Name="Tên Vật Phẩm", Description="Mô tả", Type="Loại", Equippable=true/false, Usable=true/false, Consumable=true/false, Uses=X (nếu có giới hạn)].
        9.  Nếu nhân vật bắt đầu với đồng hành, sử dụng thẻ [COMPANION: Name="Tên Đồng Hành", Description="Mô tả", Personality="AI tự quyết định", Stats="HP=Y, ATK=Z (nếu có)"].
        10. Khi giới thiệu NPC, Vật phẩm (lore), Địa điểm mới, dùng [LORE_NPC: Name, Description, Personality (AI tự quyết nếu chưa có)], [LORE_ITEM: Name, Description, Type], [LORE_LOCATION: Name, Description].
        11. Khi nhân vật nhận vật phẩm vào balo, dùng [ITEM_AQUIRED: Name, Description, Type, Equippable, Usable, Consumable, Uses].
        12. Khi nhân vật học kỹ năng mới, dùng [SKILL_LEARNED: Name, Description, Type].
        13. Khi mối quan hệ thay đổi, dùng [RELATIONSHIP_CHANGED: NPC="Tên NPC", Standing="Thân thiện/Trung lập/Thù địch/etc.", Reason="Lý do thay đổi (ngắn gọn)"].
        14. Khi vật phẩm được sử dụng và tiêu hao hoàn toàn, dùng thẻ [ITEM_CONSUMED: Name="Tên Vật Phẩm"]. Nếu chỉ giảm số lần dùng, dùng [ITEM_UPDATED: Name="Tên Vật Phẩm", Uses=X (số lần còn lại)].
        15. HỆ THỐNG NHIỆM VỤ:
            - AI có thể giao nhiệm vụ cho người chơi. Dùng thẻ: [QUEST_ASSIGNED: title="Tên Nhiệm Vụ", description="Mô tả chi tiết", objectives="Mục tiêu 1; Mục tiêu 2 (nếu có, cách nhau bởi dấu ';')", giver="Tên NPC giao (nếu có)", reward="Mô tả phần thưởng (nếu có)", isMainQuest=true/false]
            - Khi một nhiệm vụ được cập nhật (hoàn thành, thất bại), dùng thẻ: [QUEST_UPDATED: title="Tên Nhiệm Vụ", status="completed/failed"]
            - Khi một mục tiêu cụ thể của nhiệm vụ được hoàn thành (nhưng nhiệm vụ chưa kết thúc), dùng thẻ: [QUEST_OBJECTIVE_COMPLETED: questTitle="Tên Nhiệm Vụ", objectiveDescription="Mô tả mục tiêu vừa hoàn thành"]
            - Nhiệm vụ PHẢI ảnh hưởng đến diễn biến câu chuyện và lựa chọn của người chơi.
        16. Tạo 4-5 lựa chọn hành động rõ ràng, có ý nghĩa, đa dạng. Các lựa chọn phải phản ánh tính cách và mục tiêu của nhân vật, cũng như tình hình thực tế, các trạng thái và nhiệm vụ hiện tại.
        17. QUAN TRỌNG: Với một số lựa chọn có tính rủi ro, hãy mô tả ngắn gọn tỷ lệ thành công ước tính (Cao, Trung Bình, Thấp, Rất Thấp) và hậu quả tiềm ẩn nếu thành công hoặc thất bại. Tỷ lệ này phải bị ảnh hưởng bởi trạng thái, tính cách, trang bị, vật phẩm, kỹ năng của nhân vật và tình huống. Ví dụ: "1. Thử leo vách đá. (Tỷ lệ thành công: Thấp do ngươi đang [Bị Thương]. Rủi ro: Ngã nặng hơn. Phần thưởng: Tìm được lối tắt.)"
        18. Lời thoại trong ngoặc kép, tên NV đứng trước. Suy nghĩ trong *suy nghĩ* hoặc _suy nghĩ_.
        19. Duy trì độ khó. Nhân vật có thể gặp bất lợi, thất bại nhưng câu chuyện vẫn tiếp diễn.
        20. Các thẻ [TAG:...] phải ở dòng riêng. Kết thúc phản hồi CHỈ bằng danh sách lựa chọn.
    `;
    setCurrentScreen('gameplay');
    
    if (userId && isAuthReady) {
        try {
            const gamesCollectionPath = `artifacts/${appId}/users/${userId}/games`;
            const newGameRef = await addDoc(collection(db, gamesCollectionPath), {
                settings: gameSettings, 
                storyHistory: [],
                currentStory: "Đang khởi tạo...",
                currentChoices: [],
                chatHistoryForGemini: [],
                knowledgeBase: { 
                    npcs: [], items: [], locations: [], companions: [], 
                    inventory: [], playerSkills: [], relationships: [],
                    playerStatus: [], quests: [], 
                }, 
                createdAt: serverTimestamp(),
                updatedAt: serverTimestamp(),
                status: "active" 
            });
            setCurrentGameId(newGameRef.id);
            await callGeminiAPI(initialPrompt, true); 
        } catch (error) {
            console.error("Error creating new game in Firestore:", error);
            setModalMessage({ show: true, title: 'Lỗi Tạo Game', content: `Không thể tạo game mới trên server: ${error.message}`, type: 'error' });
            setCurrentScreen('setup'); 
        }
    } else {
         await callGeminiAPI(initialPrompt, true); 
    }
  };

  const handleChoice = (choiceText) => {
    const userChoiceEntry = { type: 'user_choice', content: choiceText };
    setStoryHistory(prev => [...prev, userChoiceEntry]);
    setCurrentStory(''); 
    setChoices([]);     

    const currentPersonality = gameSettings.characterPersonality; 
    const characterGoal = gameSettings.useCharacterGoal && gameSettings.characterGoal ? gameSettings.characterGoal : 'Chưa có hoặc không rõ';
    const playerStatusesString = knowledgeBase.playerStatus.map(s => `${s.name} (Ảnh hưởng: ${s.effects})`).join('; ') || 'Không có';
    const activeQuestsSummary = knowledgeBase.quests
        .filter(q => q.status === 'active')
        .map(q => `- ${q.title}: ${q.description.substring(0,50)}... (Mục tiêu: ${q.objectives && q.objectives.length > 0 ? q.objectives.filter(o => !o.completed).map(o => o.text).join(', ') || "Hoàn thành các bước tiếp theo" : "Không có mục tiêu cụ thể"})`)
        .join('\n') || "Không có nhiệm vụ nào đang hoạt động.";
    const keyKnowledgeSummary = `
        NPCs đã gặp: ${knowledgeBase.npcs.map(n => n.Name).join(', ') || "Chưa gặp ai."}
        Vật phẩm trong balo: ${knowledgeBase.inventory.map(i => i.Name).join(', ') || "Trống."}
        Kỹ năng: ${knowledgeBase.playerSkills.map(s => s.Name).join(', ') || "Chưa có."}
        Địa điểm đã biết: ${knowledgeBase.locations.map(l => l.Name).join(', ') || "Chưa khám phá."}
    `;


    const subsequentPrompt = `
        Người chơi là ${gameSettings.characterName}.
        Tính cách cốt lõi của nhân vật là: "${currentPersonality}".
        Mục tiêu chính (nếu có) là: "${characterGoal}".
        Hành động người chơi vừa chọn: "${choiceText}".

        Trạng thái hiện tại của người chơi: ${playerStatusesString}.
        Nhiệm vụ đang hoạt động:
        ${activeQuestsSummary}
        Thông tin quan trọng khác cần nhớ (tóm tắt):
        ${keyKnowledgeSummary}
        Độ khó hiện tại: ${gameSettings.difficulty} ${gameSettings.difficultyDescription ? `(${gameSettings.difficultyDescription})` : ''}.
        Cho phép nội dung NSFW: ${gameSettings.allowNsfw ? 'Có' : 'Không'}. Nếu 'Có', hãy mô tả các cảnh 18+ (tình dục, bạo lực) một cách chi tiết, trần trụi và không ngần ngại, phù hợp với tính cách nhân vật và bối cảnh.
        Cho phép nhập hành động tùy ý: ${gameSettings.allowCustomActionInput ? 'Có' : 'Không'}.
        
        Bối cảnh đã qua và lựa chọn này sẽ được cung cấp qua lịch sử hội thoại.
        Yêu cầu cụ thể, duy trì văn phong tiểu thuyết mạng Trung Quốc và cách xưng hô đã định:
        1.  Dựa trên hành động vừa chọn và bối cảnh trước đó (trong lịch sử hội thoại), hãy tiếp tục câu chuyện. QUAN TRỌNG: Tính cách cốt lõi ("${currentPersonality}") và mục tiêu chính ("${characterGoal}") của nhân vật PHẢI được thể hiện rõ ràng và nhất quán trong lời nói, suy nghĩ, hành động của họ, cũng như cách thế giới phản ứng lại. Các trạng thái đang hoạt động và nhiệm vụ hiện tại cũng PHẢI ảnh hưởng đến kết quả. Nếu lựa chọn có mô tả tỷ lệ thành công/rủi ro, hãy quyết định kết quả dựa trên các yếu tố đó và mô tả diễn biến.
        2.  Mô tả kết quả của hành động người chơi đã chọn.
        3.  Nếu nhân vật hoặc NPC nhận trạng thái mới, hoặc trạng thái cũ được chữa/hết hạn, dùng các thẻ [STATUS_APPLIED_SELF/NPC: ...], [STATUS_CURED_SELF/NPC: ...], [STATUS_EXPIRED_SELF/NPC: ...] tương ứng.
        4.  Nếu có NPC, vật phẩm (lore), địa điểm, đồng hành, vật phẩm thu thập được, kỹ năng học được, mối quan hệ thay đổi, dùng các thẻ [LORE_NPC: Name, Description, Personality (AI tự quyết nếu chưa có)], [LORE_ITEM:...], [LORE_LOCATION:...], [COMPANION: Name, Description, Personality (AI tự quyết), Stats], [ITEM_AQUIRED: Name, Description, Type, Equippable, Usable, Consumable, Uses], [SKILL_LEARNED:...], [RELATIONSHIP_CHANGED:...] TRÊN CÁC DÒNG RIÊNG BIỆT.
        5.  Nếu một vật phẩm được sử dụng và tiêu hao hoàn toàn, dùng thẻ [ITEM_CONSUMED: Name="Tên Vật Phẩm"]. Nếu chỉ giảm số lần dùng, dùng [ITEM_UPDATED: Name="Tên Vật Phẩm", Uses=X (số lần còn lại)].
        6.  CẬP NHẬT NHIỆM VỤ: Nếu hành động của người chơi ảnh hưởng đến nhiệm vụ (hoàn thành mục tiêu, hoàn thành nhiệm vụ, thất bại), hãy sử dụng các thẻ [QUEST_UPDATED: title="Tên Nhiệm Vụ", status="completed/failed"], hoặc [QUEST_OBJECTIVE_COMPLETED: questTitle="Tên Nhiệm Vụ", objectiveDescription="Mô tả mục tiêu vừa hoàn thành"]. AI cũng có thể giao nhiệm vụ mới bằng [QUEST_ASSIGNED: ...].
        7.  Tạo ra 4-5 lựa chọn hành động mới bằng tiếng Việt. CÁC LỰA CHỌN PHẢI ĐA DẠNG, CÓ Ý NGHĨA, THÚC ĐẨY CÂU CHUYỆN VÀ PHẢN ÁNH TÍNH CÁCH, MỤC TIÊU, TRẠNG THÁI VÀ NHIỆM VỤ HIỆN TẠI CỦA NHÂN VẬT. Với một số lựa chọn có tính rủi ro, hãy mô tả ngắn gọn tỷ lệ thành công ước tính và hậu quả tiềm ẩn.
        8.  QUAN TRỌNG VỀ ĐỘ KHÓ VÀ TÍNH LIÊN TỤC: Tiếp tục duy trì mức độ thử thách. Các quyết định của người chơi có thể dẫn đến hậu quả nghiêm trọng. Câu chuyện vẫn tiếp diễn dù nhân vật thất bại. Luôn ghi nhớ và đề cập đến các yếu tố quan trọng liên quan đến nhân vật và thế giới. Đảm bảo tính liên tục và logic của câu chuyện.
        9.  Duy trì các quy tắc định dạng văn bản. Kết thúc phản hồi của bạn CHỈ bằng danh sách các lựa chọn.
    `;
    callGeminiAPI(subsequentPrompt);
  };

  const handleCustomAction = (actionText) => {
    if (!actionText.trim()) {
        setModalMessage({ show: true, title: 'Hành Động Trống', content: 'Vui lòng nhập hành động của ngươi.', type: 'info' });
        return;
    }
    const customActionEntry = { type: 'user_custom_action', content: actionText };
    setStoryHistory(prev => [...prev, customActionEntry]);
    setCurrentStory('');
    setChoices([]);
    setCustomActionInput(''); 

    const currentPersonality = gameSettings.characterPersonality; 
    const characterGoal = gameSettings.useCharacterGoal && gameSettings.characterGoal ? gameSettings.characterGoal : 'Chưa có hoặc không rõ';
    const playerStatusesString = knowledgeBase.playerStatus.map(s => `${s.name} (Ảnh hưởng: ${s.effects})`).join('; ') || 'Không có';
    const activeQuestsSummary = knowledgeBase.quests
        .filter(q => q.status === 'active')
        .map(q => `- ${q.title}: ${q.description.substring(0,50)}... (Mục tiêu: ${q.objectives && q.objectives.length > 0 ? q.objectives.filter(o => !o.completed).map(o => o.text).join(', ') || "Hoàn thành các bước tiếp theo" : "Không có mục tiêu cụ thể"})`)
        .join('\n') || "Không có nhiệm vụ nào đang hoạt động.";
    const keyKnowledgeSummary = `
        NPCs đã gặp: ${knowledgeBase.npcs.map(n => n.Name).join(', ') || "Chưa gặp ai."}
        Vật phẩm trong balo: ${knowledgeBase.inventory.map(i => i.Name).join(', ') || "Trống."}
        Kỹ năng: ${knowledgeBase.playerSkills.map(s => s.Name).join(', ') || "Chưa có."}
        Địa điểm đã biết: ${knowledgeBase.locations.map(l => l.Name).join(', ') || "Chưa khám phá."}
    `;


    const subsequentPrompt = `
        Người chơi là ${gameSettings.characterName}.
        Tính cách cốt lõi của nhân vật là: "${currentPersonality}".
        Mục tiêu chính (nếu có) là: "${characterGoal}".
        Hành động tùy chỉnh người chơi vừa nhập: "${actionText}".

        Trạng thái hiện tại của người chơi: ${playerStatusesString}.
        Nhiệm vụ đang hoạt động:
        ${activeQuestsSummary}
        Thông tin quan trọng khác cần nhớ (tóm tắt):
        ${keyKnowledgeSummary}
        Độ khó hiện tại: ${gameSettings.difficulty} ${gameSettings.difficultyDescription ? `(${gameSettings.difficultyDescription})` : ''}.
        Cho phép nội dung NSFW: ${gameSettings.allowNsfw ? 'Có' : 'Không'}. Nếu 'Có', hãy mô tả các cảnh 18+ (tình dục, bạo lực) một cách chi tiết, trần trụi và không ngần ngại, phù hợp với tính cách nhân vật và bối cảnh.
        Cho phép nhập hành động tùy ý: ${gameSettings.allowCustomActionInput ? 'Có' : 'Không'}.

        Bối cảnh đã qua và hành động này sẽ được cung cấp qua lịch sử hội thoại.
        Yêu cầu cụ thể, duy trì văn phong tiểu thuyết mạng Trung Quốc và cách xưng hô đã định:
        1.  Dựa trên hành động tùy chỉnh này và bối cảnh trước đó, hãy tiếp tục câu chuyện một cách hợp lý. QUAN TRỌNG: Tính cách cốt lõi ("${currentPersonality}") và mục tiêu chính ("${characterGoal}") của nhân vật PHẢI được thể hiện rõ ràng và nhất quán trong cách nhân vật thực hiện hành động này, lời nói, suy nghĩ của họ, và kết quả của nó. Các trạng thái đang hoạt động và nhiệm vụ hiện tại cũng PHẢI ảnh hưởng đến kết quả. AI cần xem xét tỷ lệ thành công tiềm ẩn của hành động này dựa trên các yếu tố trên và quyết định kết quả.
        2.  Mô tả kết quả của hành động người chơi.
        3.  Nếu nhân vật hoặc NPC nhận trạng thái mới, hoặc trạng thái cũ được chữa/hết hạn, dùng các thẻ [STATUS_APPLIED_SELF/NPC: ...], [STATUS_CURED_SELF/NPC: ...], [STATUS_EXPIRED_SELF/NPC: ...] tương ứng.
        4.  Cập nhật LORE, COMPANIONS, ITEMS (thu thập), SKILLS (học được), RELATIONSHIPS nếu có thay đổi, theo định dạng đã hướng dẫn (bao gồm tính cách cho NPC/Companion mà AI tự quyết nếu chưa có).
        5.  Nếu một vật phẩm được sử dụng và tiêu hao hoàn toàn, dùng thẻ [ITEM_CONSUMED: Name="Tên Vật Phẩm"]. Nếu chỉ giảm số lần dùng, dùng [ITEM_UPDATED: Name="Tên Vật Phẩm", Uses=X (số lần còn lại)].
        6.  CẬP NHẬT NHIỆM VỤ: Nếu hành động của người chơi ảnh hưởng đến nhiệm vụ (hoàn thành mục tiêu, hoàn thành nhiệm vụ, thất bại), hãy sử dụng các thẻ [QUEST_UPDATED: title="Tên Nhiệm Vụ", status="completed/failed"], hoặc [QUEST_OBJECTIVE_COMPLETED: questTitle="Tên Nhiệm Vụ", objectiveDescription="Mô tả mục tiêu vừa hoàn thành"]. AI cũng có thể giao nhiệm vụ mới bằng [QUEST_ASSIGNED: ...].
        7.  Tạo ra 4-5 lựa chọn hành động mới bằng tiếng Việt. CÁC LỰA CHỌN PHẢI ĐA DẠNG, CÓ Ý NGHĨA, THÚC ĐẨY CÂU CHUYỆN VÀ PHẢN ÁNH TÍNH CÁCH, MỤC TIÊU, TRẠNG THÁI VÀ NHIỆM VỤ HIỆN TẠI CỦA NHÂN VẬT. Với một số lựa chọn có tính rủi ro, hãy mô tả ngắn gọn tỷ lệ thành công ước tính và hậu quả tiềm ẩn.
        8.  QUAN TRỌNG VỀ ĐỘ KHÓ VÀ TÍNH LIÊN TỤC: Tiếp tục duy trì mức độ thử thách cao. Các quyết định của người chơi có thể dẫn đến hậu quả nghiêm trọng. Câu chuyện vẫn tiếp diễn dù nhân vật thất bại. Luôn ghi nhớ và đề cập đến các yếu tố quan trọng liên quan đến nhân vật và thế giới. Đảm bảo tính liên tục và logic của câu chuyện.
        9.  Duy trì các quy tắc định dạng văn bản. Kết thúc phản hồi của bạn CHỈ bằng danh sách các lựa chọn.
    `;
    callGeminiAPI(subsequentPrompt);
  };

  const saveGameProgress = async (gameIdToSave, story, currentChoices, fullStoryHistory, geminiHistory, currentKnowledge) => {
    if (!userId || !gameIdToSave || !isAuthReady ) { 
        console.log("Không thể lưu game: User ID/Game ID không tồn tại hoặc auth chưa sẵn sàng.");
        return;
    }
    try {
        const gameDocRef = doc(db, `artifacts/${appId}/users/${userId}/games`, gameIdToSave);
        const dataToSave = {
            currentStory: story,
            currentChoices: currentChoices, 
            storyHistory: fullStoryHistory, 
            chatHistoryForGemini: geminiHistory, 
            knowledgeBase: currentKnowledge, 
            settings: gameSettings, 
            updatedAt: serverTimestamp(),
        };
        await setDoc(gameDocRef, dataToSave, { merge: true }); 
        console.log("Game progress saved for ID:", gameIdToSave);
    } catch (error) {
        console.error("Error saving game progress:", error);
    }
  };

  const loadGame = async (gameData) => {
    if (!gameData) return;
    
    const defaultSettings = {
        theme: '', setting: '', characterName: '', characterPersonality: PLAYER_PERSONALITIES[0], 
        characterGender: 'Không xác định', characterBackstory: '', preferredInitialSkill: '', 
        difficulty: 'Thường', difficultyDescription: '', allowNsfw: false, 
        initialWorldElements: [], useCharacterGoal: false, characterGoal: '',
        allowCustomActionInput: true, 
    };
    setGameSettings({ ...defaultSettings, ...(gameData.settings || {}) });

    setCurrentStory(gameData.currentStory || "");
    setChoices(gameData.currentChoices || []);
    setStoryHistory(gameData.storyHistory || []);
    setChatHistoryForGemini(gameData.chatHistoryForGemini || []);
    setKnowledgeBase(gameData.knowledgeBase || { 
        npcs: [], items: [], locations: [], companions: [], 
        inventory: [], playerSkills: [], relationships: [],
        playerStatus: [], quests: [], 
    }); 
    setCurrentGameId(gameData.id);
    
    if (apiMode === 'userKey' && !apiKey && userId) { 
        const userApiKey = await loadApiKey(userId);
        if (userApiKey) {
            setApiKey(userApiKey);
            setInputApiKey(userApiKey);
            setApiKeyStatus({ status: 'Đã kết nối', message: 'API Key đã được tải.', color: 'text-green-500' });
        } else {
             setApiKeyStatus({ status: 'Chưa cấu hình', message: 'Vui lòng nhập API Key của bạn.', color: 'text-yellow-500' });
             setShowApiModal(true); 
             setCurrentScreen('initial'); 
             setShowLoadGameModal(false);
             setModalMessage({ show: true, title: 'Cần API Key', content: 'Vui lòng cấu hình API Key của bạn để tiếp tục tải game.', type: 'info' });
             return;
        }
    }

    setCurrentScreen('gameplay');
    setShowLoadGameModal(false);
    console.log("Game loaded:", gameData.id);
  };
  
  const restartGame = () => {
    setConfirmationModal({
        show: true,
        title: 'Bắt Đầu Lại Game?',
        content: 'Ngươi có muốn lưu tiến trình hiện tại trước khi bắt đầu lại không?',
        onConfirm: async () => { 
            if (currentGameId && currentStory && storyHistory.length > 0) { 
                await saveGameProgress(currentGameId, currentStory, choices, storyHistory, chatHistoryForGemini, knowledgeBase);
                setModalMessage({ show: true, title: 'Đã Lưu', content: 'Tiến trình game hiện tại đã được lưu.', type: 'success' });
            }
            performRestart();
        },
        onCancel: () => { 
            performRestart();
        },
        confirmText: 'Lưu và Bắt đầu lại',
        cancelText: 'Bắt đầu lại (Không lưu)'
    });
  };

  const performRestart = () => { 
    setCurrentGameId(null); 
    setGameSettings({ 
        theme: '', setting: '', characterName: '', characterPersonality: PLAYER_PERSONALITIES[0], 
        characterGender: 'Không xác định', characterBackstory: '', preferredInitialSkill: '', 
        difficulty: 'Thường', difficultyDescription: '', allowNsfw: false, 
        initialWorldElements: [], useCharacterGoal: false, characterGoal: '',
        allowCustomActionInput: true,
    });
    setCurrentStory('');
    setChoices([]);
    setStoryHistory([]);
    setChatHistoryForGemini([]);
    setKnowledgeBase({ 
        npcs: [], items: [], locations: [], companions: [], 
        inventory: [], playerSkills: [], relationships: [],
        playerStatus: [], quests: [], 
    });
    setCustomActionInput('');
    setCurrentScreen('setup'); 
  };

  const goHome = () => {
    if (currentScreen === 'gameplay' && currentGameId && currentStory && storyHistory.length > 0) { 
         setConfirmationModal({
            show: true,
            title: 'Về Trang Chủ?',
            content: 'Ngươi có muốn lưu tiến trình game hiện tại trước khi về trang chủ không?',
            onConfirm: async () => {
                await saveGameProgress(currentGameId, currentStory, choices, storyHistory, chatHistoryForGemini, knowledgeBase);
                setModalMessage({ show: true, title: 'Đã Lưu', content: 'Tiến trình game đã được lưu.', type: 'success' });
                setCurrentScreen('initial');
            },
            onCancel: () => {
                 setCurrentScreen('initial');
            },
            confirmText: 'Lưu và Về Home',
            cancelText: 'Về Home (Không lưu)'
        });
    } else {
        setCurrentScreen('initial');
    }
  };

  const formatStoryText = useCallback((text) => {
    if (!text) return null;

    const processLine = (lineContent) => {
        let segments = [{ type: 'text', content: lineContent }];
        const allLoreEntries = [];
        if (knowledgeBase) {
            const allLoreCategories = ['companions', 'npcs', 'items', 'locations', 'inventory', 'playerSkills', 'relationships', 'playerStatus', 'quests'];
            allLoreCategories.forEach(category => {
                (knowledgeBase[category] || []).forEach(loreItem => {
                    const itemName = loreItem.Name || loreItem.NPC || loreItem.name || loreItem.title; 
                    if (itemName && itemName.trim() !== "") {
                        allLoreEntries.push({ name: itemName.trim(), category, originalItem: loreItem });
                    }
                });
            });
        }
        allLoreEntries.sort((a, b) => b.name.length - a.name.length);

        allLoreEntries.forEach(entry => {
            const { name: loreName, category, originalItem } = entry;
            const newSegments = [];
            segments.forEach(segment => {
                if (segment.type === 'text') {
                    const regex = new RegExp(`(\\b${loreName.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}\\b)`, 'gi');
                    const parts = segment.content.split(regex);
                    
                    for (let i = 0; i < parts.length; i++) {
                        if (parts[i].toLowerCase() === loreName.toLowerCase()) { 
                            newSegments.push({ type: 'lore', text: parts[i], category, loreName: originalItem.Name || originalItem.NPC || originalItem.name || originalItem.title, originalItem });
                        } else if (parts[i] !== "") {
                            newSegments.push({ type: 'text', content: parts[i] });
                        }
                    }
                } else {
                    newSegments.push(segment);
                }
            });
            segments = newSegments;
        });
        
        return segments.map((segment, index) => {
            if (segment.type === 'text') {
                let formattedSegment = segment.content;
                formattedSegment = formattedSegment.replace(/^([\w\s\u00C0-\u017F]+):\s*"(.*?)"/gm, (match, p1, p2) => `<strong class="text-blue-400">${p1.trim()}:</strong> "${p2}"`);
                formattedSegment = formattedSegment.replace(/(?<!\w)\*(.*?)\*(?!\w)/g, '<em class="text-purple-400 italic">"$1"</em>'); 
                formattedSegment = formattedSegment.replace(/(?<!\w)_(.*?)_(?!\w)/g, '<em class="text-purple-400 italic">"$1"</em>'); 
                // Updated regex to avoid matching new quest tags
                formattedSegment = formattedSegment.replace(/\[(?!PLAYER_PERSONALITY|LORE_|COMPANION|ITEM_AQUIRED|SKILL_LEARNED|RELATIONSHIP_CHANGED|ITEM_CONSUMED|ITEM_UPDATED|STATUS_APPLIED_SELF|STATUS_CURED_SELF|STATUS_EXPIRED_SELF|STATUS_APPLIED_NPC|STATUS_CURED_NPC|STATUS_EXPIRED_NPC|QUEST_ASSIGNED|QUEST_UPDATED|QUEST_OBJECTIVE_COMPLETED)(.*?)\]/g, '<span class="text-yellow-400 font-semibold">[$1]</span>'); 
                formattedSegment = formattedSegment.replace(/\*\*(.*?)\*\*/g, '<strong class="text-xl block my-2 text-green-400">$1</strong>');
                return <span key={`segment-${index}`} dangerouslySetInnerHTML={{ __html: formattedSegment }} />;
            } else if (segment.type === 'lore') {
                return (
                    <span
                        key={`lore-${segment.loreName}-${index}`}
                        className="text-cyan-400 hover:text-cyan-300 underline cursor-pointer font-semibold"
                        onClick={(e) => {
                            e.stopPropagation(); 
                            openQuickLoreModal(segment.category, segment.loreName);
                        }}
                    >
                        {segment.text}
                    </span>
                );
            }
            return null; 
        });
    };

    return text.split(/\n\s*\n/).map((paragraph, pIndex) => (
        <p key={`p-${pIndex}`} className="mb-3 leading-relaxed">
            {paragraph.split('\n').map((line, lineIndex) => (
                <React.Fragment key={`line-${lineIndex}`}>
                    {processLine(line)}
                    {lineIndex < paragraph.split('\n').length - 1 && <br />} 
                </React.Fragment>
            ))}
        </p>
    ));
  }, [knowledgeBase, openQuickLoreModal]); 

  if (!isAuthReady) {
    return (
      <div className="min-h-screen bg-gray-900 text-white flex flex-col items-center justify-center p-4 font-['Arial',_sans-serif]">
        <div className="text-2xl animate-pulse">Đang tải và xác thực...</div>
      </div>
    );
  }
  
  return (
    <div className="font-['Arial',_sans-serif] text-white">
      {currentScreen === 'initial' && (
        <InitialScreen
          setCurrentScreen={setCurrentScreen}
          setShowLoadGameModal={setShowLoadGameModal}
          savedGames={savedGames}
          apiKeyStatus={apiKeyStatus}
          userId={userId}
          setInputApiKey={setInputApiKey}
          setApiKey={setApiKey} 
          apiKey={apiKey} 
          setShowApiModal={setShowApiModal}
          apiMode={apiMode}
          setShowUpdateLogModal={setShowUpdateLogModal} // Pass to InitialScreen
        />
      )}
      {currentScreen === 'setup' && (
        <GameSetupScreen
          goHome={goHome}
          gameSettings={gameSettings}
          handleInputChange={handleInputChange}
          initializeGame={initializeGame}
          isLoading={isLoading} 
          apiKey={apiKey}
          setInputApiKey={setInputApiKey} 
          setShowApiModal={setShowApiModal} 
          handleFetchSuggestions={handleFetchSuggestions}
          isFetchingSuggestions={isFetchingSuggestions}
          handleGenerateBackstory={handleGenerateBackstory}
          isGeneratingContent={isGeneratingContent}
          apiMode={apiMode}
          handleGenerateDifficultyDescription={handleGenerateDifficultyDescription}
          isGeneratingDifficultyDesc={isGeneratingDifficultyDesc}
          addInitialWorldElement={addInitialWorldElement}
          removeInitialWorldElement={removeInitialWorldElement}
          handleInitialElementChange={handleInitialElementChange}
          handleGenerateInitialElementDescription={handleGenerateInitialElementDescription}
          isGeneratingInitialElementDesc={isGeneratingInitialElementDesc}
          handleGenerateGoal={handleGenerateGoal}
          isGeneratingGoal={isGeneratingGoal}
          handleGenerateCharacterName={handleGenerateCharacterName}
          isGeneratingCharacterName={isGeneratingCharacterName}
          handleGenerateInitialSkill={handleGenerateInitialSkill}
          isGeneratingInitialSkill={isGeneratingInitialSkill}
        />
      )}
      {currentScreen === 'gameplay' && ( 
        <GameplayScreen
          goHome={goHome}
          gameSettings={gameSettings}
          restartGame={restartGame}
          storyHistory={storyHistory}
          isLoading={isLoading} 
          currentStory={currentStory}
          choices={choices}
          handleChoice={handleChoice}
          formatStoryText={formatStoryText} 
          customActionInput={customActionInput}
          setCustomActionInput={setCustomActionInput}
          handleCustomAction={handleCustomAction}
          knowledgeBase={knowledgeBase} 
          setShowCharacterInfoModal={setShowCharacterInfoModal}
          isProcessingAction={isProcessingAction}
          handleGenerateSuggestedActions={handleGenerateSuggestedActions}
          isGeneratingSuggestedActions={isGeneratingSuggestedActions}
        />
      )}
      {showApiModal && (
        <ApiSetupModal
          inputApiKey={inputApiKey}
          setInputApiKey={setInputApiKey}
          apiKeyStatus={apiKeyStatus}
          saveApiKey={saveApiKey}
          testApiKey={testApiKey}
          isLoading={isLoading} 
          setShowApiModal={setShowApiModal}
          apiKey={apiKey} 
          setApiKeyStatus={setApiKeyStatus}
          apiMode={apiMode}
          setApiMode={setApiMode}
          setModalMessage={setModalMessage}
        />
      )}
       {showUpdateLogModal && ( // Render UpdateLogModal
            <UpdateLogModal
                show={showUpdateLogModal}
                onClose={() => setShowUpdateLogModal(false)}
                changelog={changelogData}
            />
        )}
      {showLoadGameModal && (
        <LoadGameModal
          savedGames={savedGames}
          loadGame={loadGame}
          setShowLoadGameModal={setShowLoadGameModal}
          setConfirmationModal={setConfirmationModal}
          userId={userId}
          setModalMessage={setModalMessage}
        />
      )}
      {showCharacterInfoModal && (
        <CharacterInfoModal
            knowledge={knowledgeBase}
            show={showCharacterInfoModal}
            onClose={() => setShowCharacterInfoModal(false)}
            characterPersonality={gameSettings.characterPersonality} 
            characterName={gameSettings.characterName}
        />
      )}
      {showQuickLoreModal && (
        <QuickLoreModal
            loreItem={quickLoreContent}
            show={showQuickLoreModal}
            onClose={() => setShowQuickLoreModal(false)}
        />
      )}
      <SuggestionsModal
        show={showSuggestionsModal.show}
        title={showSuggestionsModal.title || "✨ Gợi Ý"}
        suggestions={showSuggestionsModal.suggestions}
        isLoading={showSuggestionsModal.isLoading}
        onSelect={(suggestion) => {
            if (showSuggestionsModal.fieldType === 'characterGoal') {
                setGameSettings(prev => ({ ...prev, characterGoal: suggestion }));
            } else if (showSuggestionsModal.fieldType) { 
                setGameSettings(prev => ({ ...prev, [showSuggestionsModal.fieldType]: suggestion }));
            }
        }}
        onClose={() => setShowSuggestionsModal({ show: false, fieldType: null, suggestions: [], isLoading: false, title: '' })}
      />
       <SuggestedActionsModal
        show={showSuggestedActionsModal}
        suggestions={suggestedActionsList}
        isLoading={isGeneratingSuggestedActions}
        onSelect={(action) => {
            setCustomActionInput(action);
            setShowSuggestedActionsModal(false);
        }}
        onClose={() => setShowSuggestedActionsModal(false)}
      />
      <MessageModal
        show={modalMessage.show}
        title={modalMessage.title}
        content={modalMessage.content}
        type={modalMessage.type}
        onClose={() => setModalMessage({ show: false, title: '', content: '', type: 'info' })}
      />
      <ConfirmationModal
        show={confirmationModal.show}
        title={confirmationModal.title}
        content={confirmationModal.content}
        onConfirm={confirmationModal.onConfirm}
        onCancel={confirmationModal.onCancel}
        confirmText={confirmationModal.confirmText}
        cancelText={confirmationModal.cancelText}
        setConfirmationModal={setConfirmationModal}
      />
    </div>
  );
};

export default App;

