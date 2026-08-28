"""
AWS Cost Explorer Integration Example
This shows how to replace mock data with real AWS costs
"""
import boto3
from datetime import datetime, timedelta
from typing import Dict, List
import os

class AWSCostIntegration:
    """Real AWS Cost Explorer integration"""
    
    def __init__(self):
        """Initialize AWS Cost Explorer client"""
        self.ce_client = boto3.client(
            'ce',
            aws_access_key_id=os.getenv('AWS_ACCESS_KEY_ID'),
            aws_secret_access_key=os.getenv('AWS_SECRET_ACCESS_KEY'),
            region_name=os.getenv('AWS_REGION', 'us-east-1')
        )
    
    def get_monthly_cost(self) -> Dict:
        """Get total cost for current month"""
        today = datetime.now().date()
        start_of_month = today.replace(day=1)
        
        response = self.ce_client.get_cost_and_usage(
            TimePeriod={
                'Start': start_of_month.strftime('%Y-%m-%d'),
                'End': today.strftime('%Y-%m-%d')
            },
            Granularity='MONTHLY',
            Metrics=['UnblendedCost']
        )
        
        total = 0
        for result in response['ResultsByTime']:
            total += float(result['Total']['UnblendedCost']['Amount'])
        
        return {
            "total_cost": round(total, 2),
            "currency": "USD",
            "period": f"{start_of_month} to {today}",
            "days_in_month": (today - start_of_month).days
        }
    
    def get_cost_by_service(self, days: int = 30) -> List[Dict]:
        """Get cost breakdown by AWS service"""
        end_date = datetime.now().date()
        start_date = end_date - timedelta(days=days)
        
        response = self.ce_client.get_cost_and_usage(
            TimePeriod={
                'Start': start_date.strftime('%Y-%m-%d'),
                'End': end_date.strftime('%Y-%m-%d')
            },
            Granularity='DAILY',
            Metrics=['UnblendedCost'],
            GroupBy=[
                {'Type': 'DIMENSION', 'Key': 'SERVICE'}
            ]
        )
        
        # Aggregate by service
        service_costs = {}
        for result in response['ResultsByTime']:
            for group in result['Groups']:
                service = group['Keys'][0]
                cost = float(group['Metrics']['UnblendedCost']['Amount'])
                
                if service not in service_costs:
                    service_costs[service] = 0
                service_costs[service] += cost
        
        # Convert to list
        costs = []
        for service, cost in sorted(service_costs.items(), key=lambda x: x[1], reverse=True):
            costs.append({
                "service": service,
                "cost": round(cost, 2),
                "percentage": 0  # Will calculate below
            })
        
        # Calculate percentages
        total = sum(item['cost'] for item in costs)
        for item in costs:
            item['percentage'] = round((item['cost'] / total * 100), 2)
        
        return costs
    
    def get_daily_costs(self, days: int = 30) -> List[Dict]:
        """Get daily cost trends"""
        end_date = datetime.now().date()
        start_date = end_date - timedelta(days=days)
        
        response = self.ce_client.get_cost_and_usage(
            TimePeriod={
                'Start': start_date.strftime('%Y-%m-%d'),
                'End': end_date.strftime('%Y-%m-%d')
            },
            Granularity='DAILY',
            Metrics=['UnblendedCost']
        )
        
        daily_costs = []
        for result in response['ResultsByTime']:
            daily_costs.append({
                "date": result['TimePeriod']['Start'],
                "cost": round(float(result['Total']['UnblendedCost']['Amount']), 2)
            })
        
        return daily_costs
    
    def get_cost_forecast(self, days_ahead: int = 30) -> Dict:
        """Get AWS cost forecast"""
        start_date = datetime.now().date()
        end_date = start_date + timedelta(days=days_ahead)
        
        response = self.ce_client.get_cost_forecast(
            TimePeriod={
                'Start': start_date.strftime('%Y-%m-%d'),
                'End': end_date.strftime('%Y-%m-%d')
            },
            Metric='UNBLENDED_COST',
            Granularity='MONTHLY'
        )
        
        forecasted_cost = float(response['Total']['Amount'])
        
        return {
            "forecasted_cost": round(forecasted_cost, 2),
            "period": f"{start_date} to {end_date}",
            "confidence_level": "80%"  # AWS default
        }


# Example: How to integrate into main.py
"""
# In services/cost-optimizer/main.py

from aws_integration_example import AWSCostIntegration
import os

# Initialize AWS integration
aws_integration = None
if os.getenv('AWS_ACCESS_KEY_ID'):
    try:
        aws_integration = AWSCostIntegration()
        print("✓ AWS Cost Explorer connected")
    except Exception as e:
        print(f"✗ AWS connection failed: {e}")

# Original mock endpoint
@app.get("/costs/summary")
async def get_cost_summary():
    return generate_mock_costs()

# New real AWS endpoint
@app.get("/costs/aws/real")
async def get_real_aws_costs():
    if not aws_integration:
        raise HTTPException(status_code=503, detail="AWS not configured")
    
    try:
        monthly = aws_integration.get_monthly_cost()
        by_service = aws_integration.get_cost_by_service(30)
        
        return {
            "monthly_cost": monthly,
            "by_service": by_service[:10],  # Top 10 services
            "source": "AWS Cost Explorer API",
            "last_updated": datetime.utcnow().isoformat()
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Hybrid endpoint - tries real, falls back to mock
@app.get("/costs/hybrid")
async def get_hybrid_costs():
    if aws_integration:
        try:
            return await get_real_aws_costs()
        except Exception as e:
            print(f"AWS failed, using mock: {e}")
    
    return generate_mock_costs()
"""

# Example usage
if __name__ == "__main__":
    # Set environment variables first:
    # export AWS_ACCESS_KEY_ID=your_key
    # export AWS_SECRET_ACCESS_KEY=your_secret
    
    integration = AWSCostIntegration()
    
    print("=== Monthly Cost ===")
    print(integration.get_monthly_cost())
    
    print("\n=== Top 5 Services ===")
    services = integration.get_cost_by_service(30)
    for service in services[:5]:
        print(f"{service['service']}: ${service['cost']} ({service['percentage']}%)")
    
    print("\n=== Last 7 Days ===")
    daily = integration.get_daily_costs(7)
    for day in daily:
        print(f"{day['date']}: ${day['cost']}")
    
    print("\n=== 30-Day Forecast ===")
    print(integration.get_cost_forecast(30))
