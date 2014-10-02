using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SFASBilling
{
    public class SFASUser{
        string NetID;
        double Balance;
        int PIDM;
        string SPRIDEN_ID;
        string StatusCode; //Status
        string CreditIndicator;

        public SFASUser(string NetId, double balance, int syvyids_pidm, string syvyids_spriden_id, string stvests_code)
        {
            NetID = NetId;
            Balance = balance;
            PIDM = syvids_pidm;
            SPRIDEN_ID = syvyids_spriden_id;
            if (SPRIDEN_ID.length != 8)
            {
                if (SPRIDEN_ID.length > 8)
                {
                    SPRIDEN_ID = SPRIDEN_ID.substring(SPRIDEN_ID.length - 8);
                }
                else
                {
                    SPRIDEN_ID = SPRIDEN_ID.PadLeft(8, "0");
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

        //This returns a Type 1 Detail Record Line
        public string GetBatchDetailLine(string CashierUser, string BatchNumber, string DetailCode, string TermCode)
        {
            CasheirUser.PadRight(8," ");
            BatchNumber.PadLeft(5,"0");
            balance = Balance;
            if(balance < 0){ //
                balance = balance * -1;//Correct balance to string method will not include a negative sign
            }
            // string.contat("1"
            return string.Concat(CashierUser,
                BatchNumber,
                "1",//Record Type
                PIDM.ToString("D8"),//PIDM - Banner Person Identification Number
                SPRIDEN_ID,//Yale ID (If Available)
                DetailCode,//Banner Detail Code
                DateTime.Now.ToString("MMddyyyy"),//Activity Date
                (balance * 100).ToString(F0).PadLeft(9, "0"),//Amount
                CreditIndicator,//Indicates if amount should be credited or billed from student account.
                TermCode);//Term Bill is For
        }
    }
}