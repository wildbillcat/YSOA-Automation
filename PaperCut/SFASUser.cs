using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SFASBilling
{
    public class SFASUser{
        public string NetID { get; private set; }
        public double Balance {get; private set;}
        public int PIDM { get; private set; }
        public string SPRIDEN_ID { get; private set; }
        public string StatusCode { get; private set; } //Status
        public string CreditIndicator { get; private set; }

        public SFASUser(string NetId, double balance, int syvyids_pidm, string syvyids_spriden_id, string stvests_code)
        {
            NetID = NetId;
            Balance = balance;
            PIDM = syvyids_pidm;
            SPRIDEN_ID = syvyids_spriden_id;
            if (SPRIDEN_ID.Length != 9)
            {
                if (SPRIDEN_ID.Length > 9)
                {
                    SPRIDEN_ID = SPRIDEN_ID.Substring(SPRIDEN_ID.Length - 9);
                }
                else
                {
                    SPRIDEN_ID = SPRIDEN_ID.PadLeft(9, '0');
                }
            }
            StatusCode = stvests_code;
            if (balance > 0)//User has positive balance, credit account
            {
                CreditIndicator = "CR";
            }
            else
            {
                CreditIndicator = "  ";
            }
        }

        //Returns the amount to be totaled for the billing
        public int GetAmount()
        {
            return Convert.ToInt32(Math.Abs(100 * Balance));
        } 

        //This returns a Type 1 Detail Record Line
        public string GetBatchDetailRecord(string CashierUser, string BatchNumber, string DetailCode, string TermCode)
        {
            CashierUser.PadRight(8, ' ');
            BatchNumber.PadLeft(5,'0');
            double balance = Math.Abs(Balance);
            return string.Concat(CashierUser,
                BatchNumber,
                "1",//Record Type
                PIDM.ToString("D8"),//PIDM - Banner Person Identification Number
                SPRIDEN_ID,//Yale ID (If Available)
                DetailCode,//Banner Detail Code
                DateTime.Now.ToString("MMddyyyy"),//Activity Date
                (balance * 100).ToString("F0").PadLeft(9, '0'),//Amount
                CreditIndicator,//Indicates if amount should be credited or billed from student account.
                TermCode//Term Code is for what semester the Bill is attributed to
                ).PadRight(99,' ');//Pad the right to account for the following unused fields: Effective Date (8), Filler (15), User Reference 1 (8), User Reference 2 (8)
        }

        //This returns a Type 1 Detail Record Line
        public static string GetBatchHeaderRecord(string CashierUser, string BatchNumber, int BatchTotal)
        {
            if(BatchTotal > 999999999){
                throw new Exception("Batch Total is too large to be processed");
            }else if(BatchTotal <= 0){
                throw new Exception("Batch Total is too small to be processed");
            }
            return string.Concat(CashierUser,
                BatchNumber,
                "0",//Record Type
                BatchTotal.ToString().PadLeft(9, '0'),
                DateTime.Now.ToString("MMddyyyy")//Batch Date
                );
        }
    }
}